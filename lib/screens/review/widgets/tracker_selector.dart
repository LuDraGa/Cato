import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme.dart';
import '../../../models/tracker.dart';

class TrackerSelector extends StatelessWidget {
  const TrackerSelector({
    super.key,
    required this.trackers,
    required this.selectedUid,
    required this.onSelected,
  });

  final List<Tracker> trackers;
  final String? selectedUid;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: trackers.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final tracker = trackers[index];
          final selected = tracker.uid == selectedUid;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onSelected(tracker.uid);
            },
            child: AnimatedContainer(
              duration: AppDurations.short,
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs + 2,
              ),
              decoration: BoxDecoration(
                color: selected ? AppColors.inkBlack : AppColors.bgSurface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: selected
                      ? AppColors.inkBlack
                      : AppColors.inkBlack.withValues(alpha: 0.06),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(tracker.icon, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(
                    tracker.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: selected
                          ? AppColors.bgElevated
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
