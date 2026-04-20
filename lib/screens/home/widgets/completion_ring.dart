import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../../../app/theme.dart';
import '../../../providers/core_providers.dart';

class CompletionRing extends StatefulWidget {
  const CompletionRing({
    super.key,
    required this.progress,
    required this.child,
    required this.feedbackState,
  });

  final double progress;
  final Widget child;
  final HomeFeedbackState feedbackState;

  @override
  State<CompletionRing> createState() => _CompletionRingState();
}

class _CompletionRingState extends State<CompletionRing>
    with SingleTickerProviderStateMixin {
  static const SpringDescription _spring = SpringDescription(
    mass: 1,
    stiffness: 220,
    damping: 32,
  );

  late final AnimationController _controller;
  Timer? _lagTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(
      vsync: this,
      value: widget.progress.clamp(0.0, 1.0),
    );
  }

  @override
  void didUpdateWidget(covariant CompletionRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.feedbackState.pending) {
      return;
    }
    final next = widget.progress.clamp(0.0, 1.0);
    if (oldWidget.feedbackState.pending &&
        !widget.feedbackState.pending &&
        oldWidget.feedbackState.epoch != widget.feedbackState.epoch) {
      _animateTo(next);
      return;
    }
    if (oldWidget.progress != widget.progress) {
      _jumpTo(next);
    }
  }

  @override
  void dispose() {
    _lagTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final ringSize = (screenWidth * 0.40).clamp(140.0, 200.0);
    final strokeWidth = (ringSize * 0.04).clamp(6.0, 8.0);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return SizedBox(
          width: ringSize,
          height: ringSize,
          child: CustomPaint(
            painter: _CompletionRingPainter(
              progress: _controller.value.clamp(0.0, 1.0),
              strokeWidth: strokeWidth,
            ),
            child: Center(child: widget.child),
          ),
        );
      },
    );
  }

  void _animateTo(double target) {
    _lagTimer?.cancel();
    _lagTimer = Timer(const Duration(milliseconds: 50), () {
      if (!mounted) {
        return;
      }
      _controller.animateWith(
        SpringSimulation(
          _spring,
          _controller.value,
          target,
          0,
        ),
      );
    });
  }

  void _jumpTo(double target) {
    _lagTimer?.cancel();
    _controller.stop();
    _controller.value = target;
  }
}

class _CompletionRingPainter extends CustomPainter {
  const _CompletionRingPainter({
    required this.progress,
    required this.strokeWidth,
  });

  final double progress;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final insetRect = rect.deflate(strokeWidth / 2);
    const startAngle = -math.pi / 2;
    final sweep = (2 * math.pi * progress).clamp(0.0, 2 * math.pi);

    final track = Paint()
      ..color = AppColors.bgSurface
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final fill = Paint()
      ..color = AppColors.sage
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    canvas.drawArc(insetRect, 0, 2 * math.pi, false, track);
    canvas.drawArc(insetRect, startAngle, sweep, false, fill);
  }

  @override
  bool shouldRepaint(covariant _CompletionRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
