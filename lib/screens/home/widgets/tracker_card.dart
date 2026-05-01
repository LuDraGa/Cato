import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../models/tracker.dart';

class TrackerCard extends StatelessWidget {
  const TrackerCard({
    super.key,
    required this.tracker,
    required this.subtitle,
    required this.domainColor,
    required this.onTap,
    this.deEmphasized = false,
  });

  final Tracker tracker;
  final String subtitle;
  final Color domainColor;
  final VoidCallback onTap;
  final bool deEmphasized;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.short,
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        decoration: BoxDecoration(
          color: deEmphasized ? AppColors.bgSurface : AppColors.bgElevated,
          borderRadius: BorderRadius.circular(14),
          boxShadow: deEmphasized
              ? const <BoxShadow>[]
              : surfaceShadow(elevated: true),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: domainColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(tracker.icon, style: const TextStyle(fontSize: 16)),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    tracker.name,
                    style: AppTextStyles.title(
                      deEmphasized
                          ? AppColors.textSecondary
                          : AppColors.inkBlack,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: deEmphasized
                          ? AppColors.textTertiary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoggedTrackerItem extends StatelessWidget {
  const LoggedTrackerItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.tertiary = false,
  });

  final String icon;
  final String label;
  final VoidCallback onTap;
  final bool tertiary;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm + 2,
          vertical: AppSpacing.xs + 2,
        ),
        decoration: BoxDecoration(
          color: AppColors.bgSurface.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(icon, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: tertiary
                      ? AppColors.textTertiary
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
