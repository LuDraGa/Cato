import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../app/date_utils.dart';
import '../../models/metric_value.dart';
import '../../providers/core_providers.dart';
import '../../repositories/event_repository.dart';

class DevPanelScreen extends ConsumerWidget {
  const DevPanelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isar = ref.watch(isarProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Dev Panel')),
      body: FutureBuilder<Map<String, int>>(
        future: _collectionCounts(isar),
        builder: (context, snapshot) {
          final counts = snapshot.data ?? const <String, int>{};
          return ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              Text('Collections', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Domains: ${counts['domains'] ?? 0}'),
                      Text('Trackers: ${counts['trackers'] ?? 0}'),
                      Text('Events: ${counts['events'] ?? 0}'),
                      Text('AppConfig: ${counts['appConfig'] ?? 0}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => _showCollection(context, 'Domains', () async {
                  final items = await ref.read(domainRepositoryProvider).getAll();
                  return const JsonEncoder.withIndent('  ').convert(
                    items.map((item) => item.toJson()).toList(),
                  );
                }),
                child: const Text('Browse domains'),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => _showCollection(context, 'Trackers', () async {
                  final items = await ref.read(trackerRepositoryProvider).getAllActive();
                  return const JsonEncoder.withIndent('  ').convert(
                    items.map((item) => item.toJson()).toList(),
                  );
                }),
                child: const Text('Browse trackers'),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => _showCollection(context, 'Events', () async {
                  return ref.read(eventRepositoryProvider).exportJson();
                }),
                child: const Text('Browse events'),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => _seedThirtyDays(context, ref),
                child: const Text('Seed 30 days'),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () async {
                  await ref.read(eventRepositoryProvider).clearEvents();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Events cleared')),
                    );
                  }
                },
                child: const Text('Clear events'),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () async {
                  await ref.read(configLoaderProvider).resetAndReseed();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('App reset and re-seeded')),
                    );
                  }
                },
                child: const Text('Reset app'),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => _showRawConfigs(context),
                child: const Text('View raw tracker configs'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<Map<String, int>> _collectionCounts(dynamic isar) async {
    return <String, int>{
      'domains': await isar.domains.count(),
      'trackers': await isar.trackers.count(),
      'events': await isar.events.count(),
      'appConfig': await isar.appConfigs.count(),
    };
  }

  Future<void> _showCollection(
    BuildContext context,
    String title,
    Future<String> Function() loader,
  ) async {
    final payload = await loader();
    if (!context.mounted) {
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(title)),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SelectableText(payload),
          ),
        ),
      ),
    );
  }

  Future<void> _showRawConfigs(BuildContext context) async {
    final trackers = await rootBundle.loadString('assets/tracker_configs/trackers.json');
    if (!context.mounted) {
      return;
    }
    await _showCollection(context, 'Tracker Configs', () async => trackers);
  }

  Future<void> _seedThirtyDays(BuildContext context, WidgetRef ref) async {
    final trackers = await ref.read(trackerRepositoryProvider).getAllActive();
    final drafts = <EventDraft>[];
    final random = Random(42);
    for (var offset = 0; offset < 30; offset++) {
      final date = normalizeDate(DateTime.now().subtract(Duration(days: offset)));
      for (final tracker in trackers) {
        if (tracker.uid == 'tracker-snack' && offset % 3 != 0) {
          continue;
        }
        if (tracker.uid == 'tracker-vices' && offset % 4 != 0) {
          continue;
        }
        final metrics = <MetricValue>[];
        for (final field in tracker.sortedInputSchema) {
          final metric = MetricValue()..inputKey = field.key;
          switch (field.type) {
            case 'score':
              final min = field.config['min'] as int? ?? 1;
              final max = field.config['max'] as int? ?? 10;
              metric.intValue = min + random.nextInt((max - min) + 1);
            case 'text':
              metric.stringValue = '${tracker.name} note';
            case 'single_select':
              final options = List<String>.from(field.config['options'] as List? ?? const []);
              if (options.isNotEmpty) {
                metric.stringValue = options[random.nextInt(options.length)];
              }
            case 'count':
              metric.intValue = 1 + random.nextInt(3);
            case 'duration':
              metric.doubleValue = (30 + random.nextInt(90)).toDouble();
            case 'time':
              metric.stringValue = '${8 + random.nextInt(12)}:00';
          }
          if (metric.hasValue) {
            metrics.add(metric);
          }
        }
        drafts.add(
          EventDraft(
            tracker: tracker,
            effectiveDate: date,
            effectiveTime: date.add(Duration(hours: 8 + random.nextInt(12))),
            metrics: metrics,
            isBackfill: offset > 0,
          ),
        );
      }
    }
    await ref.read(eventRepositoryProvider).saveBatch(drafts);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seeded 30 days of data')),
      );
    }
  }
}
