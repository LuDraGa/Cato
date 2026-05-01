import 'package:flutter/material.dart';

import '../../../app/theme.dart';

class ChipSelector extends StatelessWidget {
  const ChipSelector({
    super.key,
    required this.options,
    required this.selectedValues,
    required this.multi,
    required this.onChanged,
  });

  final List<String> options;
  final Set<String> selectedValues;
  final bool multi;
  final ValueChanged<Set<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: options.map((option) {
        final selected = selectedValues.contains(option);
        return GestureDetector(
          onTap: () {
            final next = <String>{...selectedValues};
            if (multi) {
              if (selected) {
                next.remove(option);
              } else {
                next.add(option);
              }
            } else {
              next
                ..clear()
                ..add(option);
            }
            onChanged(next);
          },
          child: AnimatedContainer(
            duration: AppDurations.short,
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm + 2,
              vertical: AppSpacing.xs + 2,
            ),
            decoration: BoxDecoration(
              color: selected ? AppColors.sageLight : AppColors.bgSurface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: selected ? AppColors.sage : Colors.transparent,
              ),
            ),
            child: Text(
              option,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: selected ? AppColors.inkBlack : AppColors.textPrimary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
