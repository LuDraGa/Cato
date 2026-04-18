import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/date_utils.dart';
import '../../app/theme.dart';
import '../../engines/input_engine.dart';
import '../../models/tracker.dart';
import '../../providers/core_providers.dart';
import '../../providers/entry_form_provider.dart';
import '../../providers/event_providers.dart';
import '../../providers/tracker_providers.dart';
import '../../repositories/event_repository.dart';

class BatchEntryScreen extends ConsumerWidget {
  const BatchEntryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentDate = ref.watch(currentDateProvider);
    final trackers = ref.watch(completionEligibleTrackersProvider);
    final events = ref.watch(todayEventsProvider).valueOrNull ?? const [];
    final pending = trackers.where((tracker) {
      return !events.any((event) => event.trackerUid == tracker.uid);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reflect on your day',
          style: AppTextStyles.headline(AppColors.inkBlack),
        ),
      ),
      body: SafeArea(
        child: pending.isEmpty
            ? Center(
                child: Text(
                  'Everything for today is already logged.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.md,
                  AppSpacing.xl,
                  AppSpacing.xl,
                ),
                children: <Widget>[
                  Text(
                    '${pending.length} not yet logged',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ...pending.map(
                    (tracker) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _BatchCard(
                        tracker: tracker,
                        date: currentDate,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _saveAll(context, ref, pending, currentDate),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: AppColors.sage,
                        foregroundColor: AppColors.bgElevated,
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text('Save all (${pending.length})'),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _saveAll(
    BuildContext context,
    WidgetRef ref,
    List<Tracker> pending,
    DateTime currentDate,
  ) async {
    final eventRepository = ref.read(eventRepositoryProvider);
    final notificationService = ref.read(notificationServiceProvider);
    final soundEnabled = ref.read(soundEnabledProvider).valueOrNull ?? false;
    final homeFeedback = ref.read(homeFeedbackProvider.notifier);
    final drafts = <EventDraft>[];

    for (final tracker in pending) {
      final seed = EntryFormSeed(tracker: tracker, effectiveDate: currentDate);
      final controller = ref.read(entryFormProvider(seed).notifier);
      if (!controller.validate()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Finish ${tracker.name.toLowerCase()} first.')),
        );
        return;
      }
      final state = ref.read(entryFormProvider(seed));
      drafts.add(
        EventDraft(
          tracker: tracker,
          effectiveDate: state.effectiveDate,
          effectiveTime: mergeDateAndTime(state.effectiveDate, state.headerTime),
          metrics: controller.buildMetrics(),
          clearedKeys: controller.buildClearedKeys(),
          isBackfill: false,
        ),
      );
    }

    homeFeedback.beginSave();
    try {
      await eventRepository.saveBatch(drafts);
      await HapticFeedback.mediumImpact();
      if (soundEnabled) {
        await ref.read(soundServiceProvider).playSaveTap();
      }
      await notificationService.syncSchedules();
      if (context.mounted) {
        Navigator.of(context).pop();
        unawaited(
          Future<void>.delayed(
            const Duration(milliseconds: 100),
            homeFeedback.completeSave,
          ),
        );
      } else {
        homeFeedback.cancelSave();
      }
    } catch (_) {
      homeFeedback.cancelSave();
      rethrow;
    }
  }
}

class _BatchCard extends StatelessWidget {
  const _BatchCard({
    required this.tracker,
    required this.date,
  });

  final Tracker tracker;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final seed = EntryFormSeed(tracker: tracker, effectiveDate: date);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.circular(24),
        boxShadow: surfaceShadow(elevated: true),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '${tracker.icon}  ${tracker.name}',
            style: AppTextStyles.title(AppColors.inkBlack),
          ),
          const SizedBox(height: AppSpacing.md),
          DynamicEntryFields(
            seed: seed,
            showSectionHeaders: false,
          ),
        ],
      ),
    );
  }
}
