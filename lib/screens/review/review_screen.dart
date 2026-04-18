import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/date_utils.dart';
import '../../app/theme.dart';
import '../../models/tracker.dart';
import '../../providers/core_providers.dart';
import '../../providers/event_providers.dart';
import '../../providers/heatmap_providers.dart';
import '../../providers/score_providers.dart';
import '../../providers/tracker_providers.dart';
import '../entry/entry_sheet.dart';
import 'widgets/heatmap_grid.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  final ScrollController _scrollController = ScrollController();
  String _selectedDomain = 'all';
  double? _lastLoadExtent;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_maybeLoadMore);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_maybeLoadMore)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentDate = ref.watch(currentDateProvider);
    final trackers = ref.watch(allTrackersProvider).valueOrNull ?? const <Tracker>[];
    final domains = ref.watch(allDomainsProvider).valueOrNull ?? const [];
    final monthCount = ref.watch(reviewMonthCountProvider);

    final filtered = trackers.where((tracker) {
      if (tracker.heatmapMode == 'excluded') {
        return false;
      }
      return _selectedDomain == 'all' || tracker.domainUid == _selectedDomain;
    }).toList();

    final months = List<DateTime>.generate(
      monthCount,
      (index) => firstDayOfMonth(addMonths(currentDate, -index)),
    );

    return SafeArea(
      child: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.md,
          AppSpacing.xl,
          AppSpacing.xl,
        ),
        children: <Widget>[
          Text(
            'Review',
            style: AppTextStyles.display(AppColors.inkBlack),
          ),
          const SizedBox(height: AppSpacing.xl),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: <Widget>[
                _FilterChip(
                  label: 'All',
                  selected: _selectedDomain == 'all',
                  onTap: () => setState(() => _selectedDomain = 'all'),
                ),
                ...domains.map(
                  (domain) => Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.sm),
                    child: _FilterChip(
                      label: domain.name,
                      selected: _selectedDomain == domain.uid,
                      onTap: () => setState(() => _selectedDomain = domain.uid),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          ...filtered.map(
            (tracker) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
              child: _TrackerReviewSection(
                tracker: tracker,
                months: months,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _maybeLoadMore() {
    if (!_scrollController.hasClients) {
      return;
    }
    final threshold = _scrollController.position.maxScrollExtent - 400;
    if (_scrollController.position.pixels < threshold) {
      return;
    }
    final currentExtent = _scrollController.position.maxScrollExtent;
    if (_lastLoadExtent == currentExtent) {
      return;
    }
    _lastLoadExtent = currentExtent;
    if (mounted) {
      final notifier = ref.read(reviewMonthCountProvider.notifier);
      notifier.state = notifier.state + 3;
    }
  }
}

class _TrackerReviewSection extends ConsumerWidget {
  const _TrackerReviewSection({
    required this.tracker,
    required this.months,
  });

  final Tracker tracker;
  final List<DateTime> months;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(streakProvider(tracker.uid));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                tracker.name,
                style: AppTextStyles.title(AppColors.inkBlack),
              ),
            ),
            Text(
              '$streak day${streak == 1 ? '' : 's'}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        ...months.map(
          (month) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: _MonthGrid(
              tracker: tracker,
              month: month,
            ),
          ),
        ),
      ],
    );
  }
}

class _MonthGrid extends ConsumerWidget {
  const _MonthGrid({
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '${_monthName(month.month)} ${month.year}',
          style: AppTextStyles.title(AppColors.textSecondary).copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        HeatmapGrid(
          tracker: tracker,
          month: month,
          data: data,
          onTap: (date) async {
                  final events =
                      await ref.read(eventRepositoryProvider).getEventsForTrackerAndDate(
                            tracker.uid,
                            date,
                          );
            if (!context.mounted) {
              return;
            }
            await showTrackerEntrySheet(
              context: context,
              tracker: tracker,
              effectiveDate: date,
              existingEvent: events.isEmpty ? null : events.first,
              isBackfill: events.isEmpty,
            );
          },
        ),
      ],
    );
  }

  String _monthName(int month) {
    const months = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.short,
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.sageLight : AppColors.bgSurface,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: selected ? AppColors.inkBlack : AppColors.textPrimary,
              ),
        ),
      ),
    );
  }
}
