import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../providers/review_providers.dart';
import 'widgets/month_review.dart';
import 'widgets/multi_tracker_summary.dart';
import 'widgets/tracker_selector.dart';
import 'widgets/week_review.dart';
import 'widgets/year_review.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  bool _showMultiTrackerDemo = false;

  @override
  Widget build(BuildContext context) {
    final timeScale = ref.watch(reviewTimeScaleProvider);
    final trackers = ref.watch(reviewTrackersProvider);
    final selectedTracker = ref.watch(reviewEffectiveTrackerProvider);
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // ── Header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.md,
              AppSpacing.xl,
              0,
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Review',
                    style: AppTextStyles.display(AppColors.inkBlack),
                  ),
                ),
                // Multi-tracker demo toggle
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(
                        () => _showMultiTrackerDemo = !_showMultiTrackerDemo);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: AppDurations.short,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _showMultiTrackerDemo
                          ? AppColors.inkBlack
                          : AppColors.bgSurface,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.grid_view_rounded,
                          size: 14,
                          color: _showMultiTrackerDemo
                              ? AppColors.bgElevated
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'All',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _showMultiTrackerDemo
                                ? AppColors.bgElevated
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // ── Multi-tracker DEMO or single-tracker focus ──
          if (_showMultiTrackerDemo) ...[
            Expanded(
              child: MultiTrackerSummary(
                onSelectTracker: (uid) {
                  ref.read(reviewSelectedTrackerUidProvider.notifier).state = uid;
                  setState(() => _showMultiTrackerDemo = false);
                },
              ),
            ),
          ] else ...[
            // ── Time-scale tabs ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: _TimeScaleTabs(
                selected: timeScale,
                onChanged: (scale) {
                  HapticFeedback.selectionClick();
                  ref.read(reviewTimeScaleProvider.notifier).state = scale;
                },
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // ── Tracker selector ──
            TrackerSelector(
              trackers: trackers,
              selectedUid: selectedTracker?.uid,
              onSelected: (uid) {
                ref.read(reviewSelectedTrackerUidProvider.notifier).state = uid;
              },
            ),

            const SizedBox(height: AppSpacing.lg),

            // ── Main content area ──
            if (selectedTracker == null)
              Expanded(
                child: Center(
                  child: Text(
                    'No trackers to review',
                    style: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 14,
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: Column(
                  children: <Widget>[
                    // Time-scale view
                    Expanded(
                      child: _buildTimeView(timeScale, selectedTracker.uid),
                    ),

                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeView(TimeScale scale, String trackerUid) {
    final tracker = ref.watch(reviewEffectiveTrackerProvider);
    if (tracker == null) return const SizedBox.shrink();

    switch (scale) {
      case TimeScale.week:
        return WeekReview(key: ValueKey('week_$trackerUid'), tracker: tracker);
      case TimeScale.month:
        return MonthReview(key: ValueKey('month_$trackerUid'), tracker: tracker);
      case TimeScale.year:
        return YearReview(key: ValueKey('year_$trackerUid'), tracker: tracker);
    }
  }

}

// ── Time-scale tab bar ──────────────────────────────────────────────────────

class _TimeScaleTabs extends StatelessWidget {
  const _TimeScaleTabs({
    required this.selected,
    required this.onChanged,
  });

  final TimeScale selected;
  final ValueChanged<TimeScale> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: TimeScale.values.map((scale) {
          final isSelected = scale == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(scale),
              child: AnimatedContainer(
                duration: AppDurations.short,
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.bgElevated : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected
                      ? <BoxShadow>[
                          BoxShadow(
                            color: AppColors.inkBlack.withValues(alpha: 0.06),
                            offset: const Offset(0, 1),
                            blurRadius: 3,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    _label(scale),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? AppColors.inkBlack
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _label(TimeScale scale) {
    switch (scale) {
      case TimeScale.week:
        return 'Week';
      case TimeScale.month:
        return 'Month';
      case TimeScale.year:
        return 'Year';
    }
  }
}
