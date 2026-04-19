import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../models/tracker.dart';
import '../../../providers/core_providers.dart';
import '../../../providers/event_providers.dart';
import '../../../providers/heatmap_providers.dart';
import '../../../providers/review_providers.dart';
import '../../entry/entry_sheet.dart';
import 'heatmap_grid.dart';
import 'summary_stats.dart';

/// Swipeable month view for a single tracker.
/// Uses PageView for horizontal navigation between months.
class MonthReview extends ConsumerStatefulWidget {
  const MonthReview({super.key, required this.tracker});

  final Tracker tracker;

  @override
  ConsumerState<MonthReview> createState() => _MonthReviewState();
}

class _MonthReviewState extends ConsumerState<MonthReview> {
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
  void didUpdateWidget(MonthReview oldWidget) {
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

  DateTime _monthForPage(int page, DateTime now) {
    final offset = page - _centerPage;
    return DateTime(now.year, now.month + offset, 1);
  }

  @override
  Widget build(BuildContext context) {
    final currentDate = ref.watch(currentDateProvider);
    final month = _monthForPage(_currentPage, currentDate);

    return Column(
      children: <Widget>[
        _MonthNavigator(
          month: month,
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
                // Don't allow navigating past current month
                _pageController.jumpToPage(_centerPage);
                return;
              }
              setState(() => _currentPage = page);
            },
            itemBuilder: (context, page) {
              if (page > _centerPage) return const SizedBox.shrink();
              final pageMonth = _monthForPage(page, currentDate);
              return _MonthPage(
                tracker: widget.tracker,
                month: pageMonth,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MonthNavigator extends StatelessWidget {
  const _MonthNavigator({
    required this.month,
    required this.canGoForward,
    required this.onBack,
    required this.onForward,
  });

  final DateTime month;
  final bool canGoForward;
  final VoidCallback onBack;
  final VoidCallback onForward;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
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
            '${_monthName(month.month)} ${month.year}',
            style: AppTextStyles.title(AppColors.inkBlack).copyWith(fontSize: 18),
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

  static String _monthName(int month) {
    const months = <String>[
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return months[month - 1];
  }
}

class _MonthPage extends ConsumerWidget {
  const _MonthPage({
    required this.tracker,
    required this.month,
  });

  final Tracker tracker;
  final DateTime month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0);
    final data = ref.watch(
      heatmapDataProvider(
        HeatmapRequest(tracker: tracker, start: start, end: end),
      ),
    );
    final summary = ref.watch(
      periodSummaryProvider(
        PeriodSummaryRequest(
          trackerUid: tracker.uid,
          start: start,
          end: end,
        ),
      ),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        children: <Widget>[
          HeatmapGrid(
            tracker: tracker,
            month: month,
            data: data,
            onTap: (date) async {
              final events = await ref
                  .read(eventRepositoryProvider)
                  .getEventsForTrackerAndDate(tracker.uid, date);
              if (!context.mounted) return;
              await showTrackerEntrySheet(
                context: context,
                tracker: tracker,
                effectiveDate: date,
                existingEvent: events.isEmpty ? null : events.first,
                isBackfill: events.isEmpty,
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          SummaryStats(summary: summary),
        ],
      ),
    );
  }
}
