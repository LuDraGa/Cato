import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/date_utils.dart';
import '../../../app/theme.dart';
import '../../../models/event.dart';
import '../../../models/tracker.dart';
import '../../../providers/core_providers.dart';
import '../../../providers/event_providers.dart';
import '../../../providers/heatmap_providers.dart';
import '../../../providers/review_providers.dart';
import '../../entry/entry_sheet.dart';
import 'day_entry_summary.dart';
import 'summary_stats.dart';

/// Swipeable week view showing 7-day detail cards for a single tracker.
class WeekReview extends ConsumerStatefulWidget {
  const WeekReview({super.key, required this.tracker});

  final Tracker tracker;

  @override
  ConsumerState<WeekReview> createState() => _WeekReviewState();
}

class _WeekReviewState extends ConsumerState<WeekReview> {
  static const int _totalPages = 2400;
  static const int _centerPage = _totalPages ~/ 2;

  late final PageController _pageController;
  int _currentPage = _centerPage;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _centerPage);
  }

  @override
  void didUpdateWidget(WeekReview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tracker.uid != widget.tracker.uid) {
      _currentPage = _centerPage;
      _pageController.jumpToPage(_centerPage);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Returns the Monday of the week for the given page offset.
  DateTime _weekStartForPage(int page, DateTime now) {
    final today = normalizeDate(now);
    final currentMonday = today.subtract(Duration(days: (today.weekday - 1)));
    final offset = page - _centerPage;
    return currentMonday.add(Duration(days: offset * 7));
  }

  @override
  Widget build(BuildContext context) {
    final currentDate = ref.watch(currentDateProvider);
    final weekStart = _weekStartForPage(_currentPage, currentDate);
    final weekEnd = weekStart.add(const Duration(days: 6));

    return Column(
      children: <Widget>[
        _WeekNavigator(
          weekStart: weekStart,
          weekEnd: weekEnd,
          canGoForward: _currentPage < _centerPage,
          onBack: () => _pageController.previousPage(
            duration: AppDurations.medium,
            curve: Curves.easeOutCubic,
          ),
          onForward: () => _pageController.nextPage(
            duration: AppDurations.medium,
            curve: Curves.easeOutCubic,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (page) {
              if (page > _centerPage) {
                _pageController.jumpToPage(_centerPage);
                return;
              }
              setState(() => _currentPage = page);
            },
            itemBuilder: (context, page) {
              if (page > _centerPage) return const SizedBox.shrink();
              final start = _weekStartForPage(page, currentDate);
              return _WeekPage(tracker: widget.tracker, weekStart: start);
            },
          ),
        ),
      ],
    );
  }
}

class _WeekNavigator extends StatelessWidget {
  const _WeekNavigator({
    required this.weekStart,
    required this.weekEnd,
    required this.canGoForward,
    required this.onBack,
    required this.onForward,
  });

  final DateTime weekStart;
  final DateTime weekEnd;
  final bool canGoForward;
  final VoidCallback onBack;
  final VoidCallback onForward;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          GestureDetector(
            onTap: onBack,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Icon(
                Icons.chevron_left_rounded,
                color: AppColors.textSecondary,
                size: 22,
              ),
            ),
          ),
          Text(
            _formatRange(weekStart, weekEnd),
            style: AppTextStyles.title(
              AppColors.inkBlack,
            ).copyWith(fontSize: 18),
          ),
          GestureDetector(
            onTap: canGoForward ? onForward : null,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Icon(
                Icons.chevron_right_rounded,
                color: canGoForward
                    ? AppColors.textSecondary
                    : AppColors.textTertiary.withValues(alpha: 0.3),
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatRange(DateTime start, DateTime end) {
    const months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    if (start.month == end.month) {
      return '${start.day}\u2013${end.day} ${months[start.month - 1]}';
    }
    return '${start.day} ${months[start.month - 1]} \u2013 ${end.day} ${months[end.month - 1]}';
  }
}

class _WeekPage extends ConsumerWidget {
  const _WeekPage({required this.tracker, required this.weekStart});

  final Tracker tracker;
  final DateTime weekStart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    final data = ref.watch(
      heatmapDataProvider(
        HeatmapRequest(tracker: tracker, start: weekStart, end: weekEnd),
      ),
    );
    final summary = ref.watch(
      periodSummaryProvider(
        PeriodSummaryRequest(
          trackerUid: tracker.uid,
          start: weekStart,
          end: weekEnd,
        ),
      ),
    );
    final today = ref.watch(currentDateProvider);

    final days = List<DateTime>.generate(
      7,
      (i) => normalizeDate(weekStart.add(Duration(days: i))),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: <Widget>[
          // 7-day strip
          Row(
            children: days.map((date) {
              final value = data[date];
              final isFuture = date.isAfter(today);
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: date == days.first ? 0 : 3,
                    right: date == days.last ? 0 : 3,
                  ),
                  child: _DayCard(
                    date: date,
                    value: value,
                    isFuture: isFuture,
                    isToday: isSameDay(date, today),
                    tracker: tracker,
                    onTap: isFuture
                        ? null
                        : () async {
                            HapticFeedback.selectionClick();
                            final events = await ref
                                .read(eventRepositoryProvider)
                                .getEventsForTrackerAndDate(tracker.uid, date);
                            if (!context.mounted) return;
                            if (tracker.frequency == 'multi_daily' &&
                                events.isNotEmpty) {
                              await _showDayEntrySummary(
                                context: context,
                                tracker: tracker,
                                date: date,
                                events: events,
                                ref: ref,
                              );
                            } else {
                              await showTrackerEntrySheet(
                                context: context,
                                tracker: tracker,
                                effectiveDate: date,
                                existingEvent: events.isEmpty
                                    ? null
                                    : events.first,
                                isBackfill: events.isEmpty,
                              );
                            }
                          },
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.xl),
          SummaryStats(summary: summary),
        ],
      ),
    );
  }

  Future<void> _showDayEntrySummary({
    required BuildContext context,
    required Tracker tracker,
    required DateTime date,
    required List<Event> events,
    required WidgetRef ref,
  }) async {
    var currentEntryIndex = 0;
    final sortedEvents = [...events]
      ..sort(
        (a, b) => (a.effectiveTime ?? a.effectiveDate).compareTo(
          b.effectiveTime ?? b.effectiveDate,
        ),
      );

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.inkBlack.withValues(alpha: 0.15),
      builder: (sheetContext) => DayEntrySummary(
        tracker: tracker,
        date: date,
        events: events,
        onEntryTap: (event) async {
          currentEntryIndex = sortedEvents.indexOf(event);
          Navigator.of(sheetContext).pop();
          if (!context.mounted) return;
          await showTrackerEntrySheet(
            context: context,
            tracker: tracker,
            effectiveDate: date,
            existingEvent: event,
            isBackfill: event.isBackfill,
            carouselEntries: sortedEvents,
            onCarouselNext: sortedEvents.length > currentEntryIndex + 1
                ? () async {
                    currentEntryIndex++;
                    Navigator.of(context).pop();
                    if (!context.mounted) return;
                    await Future.delayed(const Duration(milliseconds: 200));
                    if (!context.mounted) return;
                    await showTrackerEntrySheet(
                      context: context,
                      tracker: tracker,
                      effectiveDate: date,
                      existingEvent: sortedEvents[currentEntryIndex],
                      isBackfill: sortedEvents[currentEntryIndex].isBackfill,
                      carouselEntries: sortedEvents,
                      onCarouselNext: null,
                      onCarouselPrevious: null,
                    );
                  }
                : null,
            onCarouselPrevious: currentEntryIndex > 0
                ? () async {
                    currentEntryIndex--;
                    Navigator.of(context).pop();
                    if (!context.mounted) return;
                    await Future.delayed(const Duration(milliseconds: 200));
                    if (!context.mounted) return;
                    await showTrackerEntrySheet(
                      context: context,
                      tracker: tracker,
                      effectiveDate: date,
                      existingEvent: sortedEvents[currentEntryIndex],
                      isBackfill: sortedEvents[currentEntryIndex].isBackfill,
                      carouselEntries: sortedEvents,
                      onCarouselNext: null,
                      onCarouselPrevious: null,
                    );
                  }
                : null,
          );
        },
        onAddNew: () async {
          Navigator.of(sheetContext).pop();
          if (!context.mounted) return;
          await showTrackerEntrySheet(
            context: context,
            tracker: tracker,
            effectiveDate: date,
          );
        },
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({
    required this.date,
    required this.value,
    required this.isFuture,
    required this.isToday,
    required this.tracker,
    this.onTap,
  });

  final DateTime date;
  final double? value;
  final bool isFuture;
  final bool isToday;
  final Tracker tracker;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hasData = value != null;
    final color = _colorFor(value);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.short,
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isFuture
              ? AppColors.bgSurface.withValues(alpha: 0.5)
              : hasData
              ? color
              : AppColors.bgSurface,
          borderRadius: BorderRadius.circular(10),
          border: isToday
              ? Border.all(
                  color: AppColors.inkBlack.withValues(alpha: 0.15),
                  width: 1.5,
                )
              : Border.all(color: AppColors.inkBlack.withValues(alpha: 0.04)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              _dayAbbrev(date.weekday),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isFuture
                    ? AppColors.textTertiary.withValues(alpha: 0.4)
                    : AppColors.textTertiary,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${date.day}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isFuture
                    ? AppColors.textTertiary.withValues(alpha: 0.3)
                    : hasData && value! >= 0.55
                    ? AppColors.bgElevated.withValues(alpha: 0.9)
                    : AppColors.inkBlack,
              ),
            ),
            if (hasData && tracker.scoreKey != null) ...[
              const SizedBox(height: 4),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: value! >= 0.55
                      ? AppColors.bgElevated.withValues(alpha: 0.6)
                      : AppColors.inkBlack.withValues(alpha: 0.2),
                ),
              ),
            ] else if (!hasData && !isFuture) ...[
              const SizedBox(height: 4),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _colorFor(double? v) {
    if (v == null) return AppColors.heatNoData;
    if (tracker.heatmapMode == 'presence') return AppColors.sage;
    if (v <= 0.10) return AppColors.heatMinimal;
    if (v <= 0.30) return AppColors.heatLow;
    if (v <= 0.55) return AppColors.heatMid;
    if (v <= 0.75) return AppColors.heatHigh;
    if (v <= 0.92) return AppColors.heatStrong;
    return AppColors.heatPeak;
  }

  String _dayAbbrev(int weekday) {
    const days = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    return days[weekday - 1];
  }
}
