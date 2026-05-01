import 'package:flutter/material.dart';

import '../app/theme.dart';

/// A small ⓘ button that shows a tooltip on tap.
///
/// Drop next to any label or control that needs a brief explanation.
/// ```dart
/// Row(children: [
///   Text('Duration'),
///   const SizedBox(width: 4),
///   InfoTip(message: 'Toggle between duration and sleep/wake times'),
/// ])
/// ```
class InfoTip extends StatelessWidget {
  const InfoTip({super.key, required this.message, this.iconSize = 14});

  final String message;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final key = GlobalKey<TooltipState>();
    return Tooltip(
      key: key,
      message: message,
      preferBelow: false,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.inkBlack.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(10),
      ),
      textStyle: TextStyle(
        color: AppColors.bgElevated,
        fontSize: 12,
        height: 1.4,
      ),
      triggerMode: TooltipTriggerMode.manual,
      showDuration: const Duration(seconds: 3),
      child: GestureDetector(
        onTap: () => key.currentState?.ensureTooltipVisible(),
        child: Icon(
          Icons.info_outline_rounded,
          size: iconSize,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }
}
