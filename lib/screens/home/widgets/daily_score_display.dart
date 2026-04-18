import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../providers/core_providers.dart';

class DailyScoreDisplay extends StatefulWidget {
  const DailyScoreDisplay({
    super.key,
    required this.score,
    required this.feedbackState,
  });

  final int? score;
  final HomeFeedbackState feedbackState;

  @override
  State<DailyScoreDisplay> createState() => _DailyScoreDisplayState();
}

class _DailyScoreDisplayState extends State<DailyScoreDisplay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Animation<int>? _scoreAnimation;
  int? _visibleScore;
  int? _targetScore;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.long,
    );
    _controller.addListener(() => setState(() {}));
    _targetScore = widget.score;
    _visibleScore = widget.score;
    if (widget.score != null) {
      _scoreAnimation = AlwaysStoppedAnimation<int>(widget.score!);
    }
  }

  @override
  void didUpdateWidget(covariant DailyScoreDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.feedbackState.pending) {
      return;
    }
    if (oldWidget.feedbackState.pending &&
        !widget.feedbackState.pending &&
        oldWidget.feedbackState.epoch != widget.feedbackState.epoch) {
      _animateTo(widget.score);
      return;
    }
    if (oldWidget.score != widget.score) {
      _setImmediate(widget.score);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_targetScore == null) {
      return Text(
        '—',
        style: AppTextStyles.metric(AppColors.inkBlack),
      );
    }
    final value = _controller.isAnimating
        ? _scoreAnimation?.value ?? _targetScore!
        : _visibleScore ?? _targetScore!;
    return Text(
      value.toString(),
      style: AppTextStyles.metric(AppColors.inkBlack),
    );
  }

  void _animateTo(int? score) {
    if (score == null) {
      _setImmediate(null);
      return;
    }

    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 150), () {
      if (!mounted) {
        return;
      }
      final begin = _visibleScore ?? score;
      if (begin == score) {
        _setImmediate(score);
        return;
      }

      final curved = CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      );
      setState(() {
        _targetScore = score;
        _scoreAnimation = StepTween(begin: begin, end: score).animate(curved);
      });
      _controller.reset();
      _controller.forward().whenCompleteOrCancel(() {
        if (mounted) {
          setState(() {
            _visibleScore = score;
          });
        }
      });
    });
  }

  void _setImmediate(int? score) {
    _timer?.cancel();
    _controller.stop();
    setState(() {
      _targetScore = score;
      _visibleScore = score;
      _scoreAnimation = score == null
          ? null
          : AlwaysStoppedAnimation<int>(score);
    });
  }
}
