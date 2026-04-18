import 'package:flutter/material.dart';

import '../../../app/theme.dart';

class CountStepper extends StatelessWidget {
  const CountStepper({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        _StepperButton(
          icon: Icons.remove_rounded,
          enabled: value > min,
          onTap: () => onChanged((value - 1).clamp(min, max)),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: GestureDetector(
            onLongPress: () => _showManualInput(context),
            child: Container(
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                '$value',
                style: AppTextStyles.metric(AppColors.inkBlack).copyWith(
                  fontSize: 24,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        _StepperButton(
          icon: Icons.add_rounded,
          enabled: value < max,
          onTap: () => onChanged((value + 1).clamp(min, max)),
        ),
      ],
    );
  }

  Future<void> _showManualInput(BuildContext context) async {
    final controller = TextEditingController(text: '$value');
    final result = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.bgElevated,
          title: const Text('Set count'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(
                  int.tryParse(controller.text)?.clamp(min, max),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    if (result != null) {
      onChanged(result);
    }
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: enabled ? AppColors.bgSurface : AppColors.bgPrimary,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          color: enabled ? AppColors.inkBlack : AppColors.textTertiary,
        ),
      ),
    );
  }
}

