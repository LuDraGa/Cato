import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../app/theme.dart';
import '../../../models/event.dart';
import '../../../models/tracker.dart';

/// Summary view for all entries of a tracker on a single date.
/// Displays entries sorted by time with an "Add New" button.
class DayEntrySummary extends StatelessWidget {
  const DayEntrySummary({
    super.key,
    required this.tracker,
    required this.date,
    required this.events,
    required this.onEntryTap,
    required this.onAddNew,
  });

  final Tracker tracker;
  final DateTime date;
  final List<Event> events;
  final Function(Event) onEntryTap;
  final VoidCallback onAddNew;

  @override
  Widget build(BuildContext context) {
    final sortedEvents = [...events]..sort((a, b) => (a.effectiveTime ?? a.effectiveDate).compareTo(b.effectiveTime ?? b.effectiveDate));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm),
          child: Text(
            '${tracker.icon} ${tracker.name} · ${MaterialLocalizations.of(context).formatMediumDate(date)}',
            style: AppTextStyles.title(AppColors.inkBlack),
          ),
        ),
        Flexible(
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: sortedEvents.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final event = sortedEvents[index];
              return _EntryListItem(
                event: event,
                tracker: tracker,
                onTap: () => onEntryTap(event),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onAddNew,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: AppColors.sage,
                foregroundColor: AppColors.bgElevated,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Add New Entry'),
            ),
          ),
        ),
      ],
    );
  }
}

class _EntryListItem extends StatelessWidget {
  const _EntryListItem({
    required this.event,
    required this.tracker,
    required this.onTap,
  });

  final Event event;
  final Tracker tracker;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final time = event.effectiveTime;
    final timeStr = time != null ? DateFormat('HH:mm').format(time) : '—';
    final summary = _buildMetricSummary();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.inkBlack.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: <Widget>[
            Text(
              timeStr,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                summary,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }

  String _buildMetricSummary() {
    if (event.metrics.isEmpty) return 'No data';
    final parts = event.metrics.take(2).map((m) {
      if (m.stringValue != null) return m.stringValue!;
      if (m.intValue != null) return m.intValue.toString();
      if (m.doubleValue != null) return m.doubleValue!.toStringAsFixed(1);
      return '—';
    }).toList();
    return parts.join(' · ');
  }
}
