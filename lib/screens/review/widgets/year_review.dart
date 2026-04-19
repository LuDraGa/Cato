import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/date_utils.dart';
import '../../../app/theme.dart';
import '../../../models/tracker.dart';
import '../../../providers/core_providers.dart';
import '../../../providers/event_providers.dart';
import '../../../providers/heatmap_providers.dart';
import '../../../providers/review_providers.dart';
import '../../entry/entry_sheet.dart';
import 'summary_stats.dart';

/// Swipeable year view — GitHub-style contribution grid.
/// Rows = days of week (Mon–Sun), columns = weeks of year.
class YearReview extends ConsumerStatefulWidget {
  const YearReview({super.key, required this.tracker});

  final Tracker tracker;

  @override
  ConsumerState<YearReview> createState() => _YearReviewState();
}

class _YearReviewState extends ConsumerState<YearReview> {
  static const int _totalPages = 200;
  static const int _centerPage = _totalPages ~/ 2;

  late final PageController _pageController;
  int _currentPage = _centerPage;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _centerPage);
  }

  @override
  void didUpdateWidget(YearReview oldWidget) {
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

  int _yearForPage(int page, DateTime now) {
    return now.year + (page - _centerPage);
  }

  @override
  Widget build(BuildContext context) {
    final currentDate = ref.watch(currentDateProvider);
    final year = _yearForPage(_currentPage, currentDate);

    return Column(
      children: <Widget>[
        _YearNavigator(
          year: year,
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
              final y = _yearForPage(page, currentDate);
              return _YearPage(tracker: widget.tracker, year: y);
            },
          ),
        ),
      ],
    );
  }
}

class _YearNavigator extends StatelessWidget {
  const _YearNavigator({
    required this.year,
    required this.canGoForward,
    required this.onBack,
    required this.onForward,
  });

  final int year;
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
            '$year',
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
}

class _YearPage extends ConsumerWidget {
  const _YearPage({required this.tracker, required this.year});

  final Tracker tracker;
  final int year;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final start = DateTime(year, 1, 1);
    final end = DateTime(year, 12, 31);
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
          _YearGrid(
            tracker: tracker,
            year: year,
            data: data,
            onTap: (date) async {
              HapticFeedback.selectionClick();
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
          const SizedBox(height: AppSpacing.md),
          _MonthLabels(year: year),
          const SizedBox(height: AppSpacing.xl),
          SummaryStats(summary: summary),
        ],
      ),
    );
  }
}

class _MonthLabels extends StatelessWidget {
  const _MonthLabels({required this.year});

  final int year;

  @override
  Widget build(BuildContext context) {
    const labels = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: labels
          .map((l) => Text(
                l,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textTertiary,
                ),
              ))
          .toList(),
    );
  }
}

class _YearGrid extends StatelessWidget {
  const _YearGrid({
    required this.tracker,
    required this.year,
    required this.data,
    required this.onTap,
  });

  final Tracker tracker;
  final int year;
  final Map<DateTime, double?> data;
  final ValueChanged<DateTime> onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final jan1 = DateTime(year, 1, 1);
        final dec31 = DateTime(year, 12, 31);
        final startOffset = (jan1.weekday - 1) % 7; // 0=Mon
        final totalDays = dec31.difference(jan1).inDays + 1;
        final totalWeeks = ((startOffset + totalDays) / 7).ceil();

        const rows = 7;
        const gap = 2.0;
        final cellSize =
            (constraints.maxWidth - (totalWeeks - 1) * gap) / totalWeeks;
        final gridHeight = rows * cellSize + (rows - 1) * gap;

        // Build cells
        final cells = <_YearCell>[];
        for (var dayIndex = 0; dayIndex < totalDays; dayIndex++) {
          final date = normalizeDate(jan1.add(Duration(days: dayIndex)));
          final cellIndex = startOffset + dayIndex;
          final col = cellIndex ~/ 7;
          final row = cellIndex % 7;
          final value = data[date];

          cells.add(_YearCell(
            date: date,
            rect: Rect.fromLTWH(
              col * (cellSize + gap),
              row * (cellSize + gap),
              cellSize,
              cellSize,
            ),
            color: _colorFor(value),
            filled: value != null,
          ));
        }

        return SizedBox(
          width: constraints.maxWidth,
          height: gridHeight,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (details) {
              for (final cell in cells) {
                if (cell.rect.contains(details.localPosition)) {
                  final today = normalizeDate(DateTime.now());
                  if (!cell.date.isAfter(today)) {
                    onTap(cell.date);
                  }
                  return;
                }
              }
            },
            child: CustomPaint(
              painter: _YearGridPainter(cells: cells),
            ),
          ),
        );
      },
    );
  }

  Color _colorFor(double? value) {
    if (value == null) return AppColors.heatNoData;
    if (tracker.heatmapMode == 'presence') return AppColors.sage;
    if (value <= 0.10) return AppColors.heatMinimal;
    if (value <= 0.30) return AppColors.heatLow;
    if (value <= 0.55) return AppColors.heatMid;
    if (value <= 0.75) return AppColors.heatHigh;
    if (value <= 0.92) return AppColors.heatStrong;
    return AppColors.heatPeak;
  }
}

class _YearCell {
  const _YearCell({
    required this.date,
    required this.rect,
    required this.color,
    required this.filled,
  });

  final DateTime date;
  final Rect rect;
  final Color color;
  final bool filled;
}

class _YearGridPainter extends CustomPainter {
  const _YearGridPainter({required this.cells});

  final List<_YearCell> cells;

  @override
  void paint(Canvas canvas, Size size) {
    for (final cell in cells) {
      final radius = math.min(cell.rect.width * 0.25, 3.0);
      final rrect = RRect.fromRectAndRadius(cell.rect, Radius.circular(radius));
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = cell.color
          ..isAntiAlias = true,
      );
      // Subtle border
      canvas.drawRRect(
        rrect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5
          ..color = AppColors.inkBlack.withValues(alpha: cell.filled ? 0.04 : 0.03)
          ..isAntiAlias = true,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _YearGridPainter oldDelegate) {
    return oldDelegate.cells != cells;
  }
}
