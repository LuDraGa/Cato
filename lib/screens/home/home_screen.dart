import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/theme.dart';
import '../../providers/core_providers.dart';
import '../../providers/event_providers.dart';
import '../../providers/score_providers.dart';
import '../../providers/tracker_providers.dart';
import '../../providers/theme_provider.dart';
import '../entry/entry_sheet.dart';
import 'widgets/completion_ring.dart';
import 'widgets/daily_score_display.dart';
import 'widgets/streak_badge.dart';
import 'widgets/tracker_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late HomeSections _visibleSections;
  int _streakBeforeSave = 0;

  @override
  void initState() {
    super.initState();
    _visibleSections = ref.read(homeSectionsProvider);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(aestheticRevisionProvider);
    final today = ref.watch(currentDateProvider);
    final domains = ref.watch(domainsByUidProvider);
    final latestHomeSections = ref.watch(homeSectionsProvider);
    final feedbackState = ref.watch(homeFeedbackProvider);
    final completion = ref.watch(completionProvider);
    final score = ref.watch(dailyScoreProvider);
    final streak = ref.watch(globalStreakProvider);

    ref.listen<HomeSections>(homeSectionsProvider, (previous, next) {
      if (ref.read(homeFeedbackProvider).pending || !mounted) {
        return;
      }
      setState(() {
        _visibleSections = next;
      });
    });

    ref.listen<HomeFeedbackState>(homeFeedbackProvider, (previous, next) {
      if (previous?.pending != true && next.pending) {
        _streakBeforeSave = ref.read(globalStreakProvider);
        return;
      }
      if (previous?.pending != true || next.pending || !mounted) {
        return;
      }
      setState(() {
        _visibleSections = ref.read(homeSectionsProvider);
      });
      final streakAfterSave = ref.read(globalStreakProvider);
      if (previous?.epoch != next.epoch &&
          streakAfterSave != _streakBeforeSave &&
          _isStreakMilestone(streakAfterSave)) {
        unawaited(HapticFeedback.heavyImpact());
      }
    });

    final homeSections = feedbackState.pending ? _visibleSections : latestHomeSections;

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: <Widget>[
                    Text(
                      DateFormat('EEEE, MMMM d').format(today),
                      style: AppTextStyles.headline(AppColors.inkBlack),
                    ),
                    StreakBadge(
                      streak: streak,
                      feedbackState: feedbackState,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Center(
                  child: CompletionRing(
                    progress: completion.progress,
                    feedbackState: feedbackState,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        DailyScoreDisplay(
                          score: score,
                          feedbackState: feedbackState,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          completion.completed == 0
                              ? 'Today · not yet logged'
                              : '${completion.completed} of ${completion.total} logged',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: completion.completed == 0
                                    ? AppColors.textTertiary
                                    : AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                ...homeSections.pendingActionable.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: TrackerCard(
                      tracker: item.tracker,
                      subtitle: 'Tap to log',
                      domainColor: _domainColor(domains[item.tracker.domainUid]?.color),
                      onTap: () => showTrackerEntrySheet(
                        context: context,
                        tracker: item.tracker,
                        effectiveDate: today,
                      ),
                    ),
                  ),
                ),
                if (homeSections.pendingActionable.length > 1)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: GestureDetector(
                      onTap: () => context.push('/batch'),
                      child: Text(
                        'Log the rest →',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ),
                  ),
                ...homeSections.pendingSupplemental.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: TrackerCard(
                      tracker: item.tracker,
                      subtitle: 'Optional, kept separate',
                      domainColor: _domainColor(domains[item.tracker.domainUid]?.color),
                      deEmphasized: item.deEmphasized,
                      onTap: () => showTrackerEntrySheet(
                        context: context,
                        tracker: item.tracker,
                        effectiveDate: today,
                      ),
                    ),
                  ),
                ),
                if (homeSections.logged.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Text(
                      'Logged',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textTertiary,
                          ),
                    ),
                  ),
                if (homeSections.logged.isNotEmpty)
                  LayoutBuilder(
                    builder: (context, loggedConstraints) {
                      final itemWidth =
                          (loggedConstraints.maxWidth - AppSpacing.sm) / 2;
                      final pills = <Widget>[];
                      for (final item in homeSections.logged) {
                        if (item.tracker.frequency == 'multi_daily') {
                          for (final event in item.events) {
                            pills.add(
                              SizedBox(
                                width: itemWidth,
                                child: LoggedTrackerItem(
                                  icon: item.tracker.icon,
                                  label: item.tracker.name,
                                  tertiary: item.deEmphasized,
                                  onTap: () => showTrackerEntrySheet(
                                    context: context,
                                    tracker: item.tracker,
                                    effectiveDate: today,
                                    existingEvent: event,
                                    isBackfill: event.isBackfill,
                                  ),
                                ),
                              ),
                            );
                          }
                        } else {
                          final event = item.primaryEvent;
                          pills.add(
                            SizedBox(
                              width: itemWidth,
                              child: LoggedTrackerItem(
                                icon: item.tracker.icon,
                                label: item.scoreLabel == null
                                    ? item.tracker.name
                                    : '${item.tracker.name} · ${item.scoreLabel}',
                                tertiary: item.deEmphasized,
                                onTap: () => showTrackerEntrySheet(
                                  context: context,
                                  tracker: item.tracker,
                                  effectiveDate: today,
                                  existingEvent: event,
                                  isBackfill: event?.isBackfill ?? false,
                                ),
                              ),
                            ),
                          );
                        }
                      }
                      return Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: pills,
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _domainColor(String? color) {
    if (color == null || color.isEmpty) {
      return AppColors.sage;
    }
    final cleaned = color.replaceFirst('#', '');
    return Color(int.parse('FF$cleaned', radix: 16));
  }

  bool _isStreakMilestone(int streak) {
    return streak == 7 || streak == 30 || streak == 100;
  }
}
