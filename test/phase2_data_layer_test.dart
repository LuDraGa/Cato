import 'dart:io';
import 'dart:ffi';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'package:cato/models/event.dart';
import 'package:cato/models/input_field_schema.dart';
import 'package:cato/models/metric_value.dart';
import 'package:cato/models/tracker.dart';
import 'package:cato/providers/entry_form_provider.dart';
import 'package:cato/repositories/event_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Isar.initializeIsarCore(
      libraries: <Abi, String>{
        Abi.macosArm64: _isarCoreLibraryPath(),
        Abi.macosX64: _isarCoreLibraryPath(),
      },
    );
  });

  group('Phase 2 data layer', () {
    test('entry form only marks current-schema empty fields as cleared', () {
      final tracker = _trackerWithFields();
      final existingEvent = _eventWithMetrics(<MetricValue>[
        _intMetric('score', 7),
        _stringMetric('notes', 'Before'),
        _stringMetric('legacy_notes', 'Keep me'),
      ]);

      final controller = EntryFormController(
        EntryFormSeed(
          tracker: tracker,
          effectiveDate: DateTime(2026, 4, 18),
          existingEvent: existingEvent,
        ),
      );

      controller.setString('notes', null);

      expect(controller.buildClearedKeys(), <String>{'notes'});
    });

    test(
      'event repository preserves unknown metrics while clearing current ones',
      () async {
        final directory = await Directory.systemTemp.createTemp(
          'cato_phase2_data_layer_',
        );
        final isar = await Isar.open(
          <CollectionSchema<dynamic>>[EventSchema],
          directory: directory.path,
          name: 'phase2_data_layer_test',
          inspector: false,
        );
        addTearDown(() async {
          await isar.close(deleteFromDisk: true);
          if (directory.existsSync()) {
            await directory.delete(recursive: true);
          }
        });

        final repository = EventRepository(isar);
        final tracker = _trackerWithFields();
        final originalEvent = _eventWithMetrics(<MetricValue>[
          _intMetric('score', 7),
          _stringMetric('notes', 'Before'),
          _stringMetric('legacy_notes', 'Keep me'),
        ]);

        await isar.writeTxn(() async {
          await isar.events.put(originalEvent);
        });

        final saved = await repository.upsertDraft(
          EventDraft(
            tracker: tracker,
            effectiveDate: DateTime(2026, 4, 18),
            effectiveTime: DateTime(2026, 4, 18, 20),
            metrics: <MetricValue>[_intMetric('score', 8)],
            clearedKeys: <String>{'notes'},
            isBackfill: false,
            existingEvent: originalEvent,
          ),
        );

        final metricsByKey = <String, MetricValue>{
          for (final metric in saved.metrics) metric.inputKey: metric,
        };

        expect(metricsByKey['score']?.intValue, 8);
        expect(metricsByKey.containsKey('notes'), isFalse);
        expect(metricsByKey['legacy_notes']?.stringValue, 'Keep me');
      },
    );
  });
}

String _isarCoreLibraryPath() {
  final home = Platform.environment['HOME'];
  if (home == null || home.isEmpty) {
    throw StateError('HOME is missing for Isar test initialization.');
  }
  return '$home/.pub-cache/hosted/pub.dev/isar_flutter_libs-3.1.0+1/macos/libisar.dylib';
}

Tracker _trackerWithFields() {
  return Tracker()
    ..uid = 'tracker-mood'
    ..domainUid = 'domain-mind'
    ..name = 'Mood'
    ..icon = '😊'
    ..frequency = 'daily'
    ..promptTimes = <String>['15:00']
    ..inputSchema = <InputFieldSchema>[
      _field(
        key: 'score',
        label: 'Score',
        type: 'score',
        isRequired: true,
        sortOrder: 0,
      ),
      _field(
        key: 'notes',
        label: 'Notes',
        type: 'text',
        isRequired: false,
        sortOrder: 1,
      ),
    ]
    ..allowedVisualizations = <String>['heatmap', 'streak']
    ..scoreContribution = true
    ..scoreKey = 'score'
    ..scoreMin = 1
    ..scoreMax = 10
    ..countsForCompletion = true
    ..heatmapMode = 'score_average'
    ..sortOrder = 0
    ..isActive = true
    ..version = 2
    ..createdAt = DateTime(2026, 4, 18);
}

InputFieldSchema _field({
  required String key,
  required String label,
  required String type,
  required bool isRequired,
  required int sortOrder,
}) {
  return InputFieldSchema()
    ..key = key
    ..label = label
    ..type = type
    ..configJson = null
    ..isRequired = isRequired
    ..sortOrder = sortOrder;
}

Event _eventWithMetrics(List<MetricValue> metrics) {
  return Event()
    ..uid = 'event-1'
    ..trackerUid = 'tracker-mood'
    ..effectiveDate = DateTime(2026, 4, 18)
    ..effectiveTime = DateTime(2026, 4, 18, 18)
    ..createdAt = DateTime(2026, 4, 18, 18)
    ..updatedAt = DateTime(2026, 4, 18, 18)
    ..isBackfill = false
    ..trackerVersion = 1
    ..metrics = metrics;
}

MetricValue _intMetric(String key, int value) {
  return MetricValue()
    ..inputKey = key
    ..intValue = value;
}

MetricValue _stringMetric(String key, String value) {
  return MetricValue()
    ..inputKey = key
    ..stringValue = value;
}
