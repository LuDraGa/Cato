import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme.dart';

class ScoreSlider extends StatefulWidget {
  const ScoreSlider({
    super.key,
    required this.min,
    required this.max,
    required this.value,
    required this.onChanged,
  });

  final int min;
  final int max;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  State<ScoreSlider> createState() => _ScoreSliderState();
}

class _ScoreSliderState extends State<ScoreSlider> {
  void _updateFromDx(double localDx, double width) {
    final steps = widget.max - widget.min;
    if (steps <= 0) {
      return;
    }
    final clamped = localDx.clamp(0.0, width);
    final value = widget.min + ((clamped / width) * steps).round();
    final next = value.clamp(widget.min, widget.max);
    if (next == widget.value) {
      return;
    }
    HapticFeedback.selectionClick();
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final steps = widget.max - widget.min;
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) => _updateFromDx(
            details.localPosition.dx,
            constraints.maxWidth,
          ),
          onHorizontalDragUpdate: (details) => _updateFromDx(
            details.localPosition.dx,
            constraints.maxWidth,
          ),
          child: SizedBox(
            height: 36,
            child: CustomPaint(
              painter: _ScoreSliderPainter(
                min: widget.min,
                max: widget.max,
                value: widget.value,
                steps: steps,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ScoreSliderPainter extends CustomPainter {
  const _ScoreSliderPainter({
    required this.min,
    required this.max,
    required this.value,
    required this.steps,
  });

  final int min;
  final int max;
  final int value;
  final int steps;

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    final trackPaint = Paint()
      ..color = AppColors.bgSurface
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
    final fillPaint = Paint()
      ..color = AppColors.sage
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final start = Offset(6, centerY);
    final end = Offset(size.width - 6, centerY);
    canvas.drawLine(start, end, trackPaint);

    final ratio = steps == 0 ? 0.0 : (value - min) / steps;
    final fillEnd = Offset(start.dx + (end.dx - start.dx) * ratio, centerY);
    canvas.drawLine(start, fillEnd, fillPaint);

    final dotPaint = Paint()..color = AppColors.bgElevated;
    final activeDotPaint = Paint()..color = AppColors.sage;

    final count = max - min + 1;
    for (var index = 0; index < count; index++) {
      final ratio = count == 1 ? 0.0 : index / (count - 1);
      final dx = start.dx + (end.dx - start.dx) * ratio;
      final circleValue = min + index;
      final radius = circleValue == value ? 6.5 : 4.5;
      final paint = circleValue <= value ? activeDotPaint : dotPaint;
      canvas.drawCircle(Offset(dx, centerY), radius, paint);
      canvas.drawCircle(
        Offset(dx, centerY),
        radius,
        Paint()
          ..color = AppColors.inkBlack.withValues(alpha: 0.08)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ScoreSliderPainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.min != min ||
        oldDelegate.max != max;
  }
}
