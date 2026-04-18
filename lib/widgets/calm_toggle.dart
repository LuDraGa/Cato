import 'package:flutter/material.dart';

import '../app/theme.dart';

class CalmToggle extends StatelessWidget {
  const CalmToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: AppDurations.short,
        curve: Curves.easeOutCubic,
        width: 54,
        height: 32,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? AppColors.sage : AppColors.bgSurface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: value ? AppColors.sage : AppColors.textTertiary,
            width: 1,
          ),
        ),
        child: AnimatedAlign(
          duration: AppDurations.short,
          curve: Curves.easeOutCubic,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: AppColors.bgElevated,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

