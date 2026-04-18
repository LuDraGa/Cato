import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../providers/core_providers.dart';

class StreakBadge extends StatefulWidget {
  const StreakBadge({
    super.key,
    required this.streak,
    required this.feedbackState,
  });

  final int streak;
  final HomeFeedbackState feedbackState;

  @override
  State<StreakBadge> createState() => _StreakBadgeState();
}

class _StreakBadgeState extends State<StreakBadge> {
  int _visible = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _visible = widget.streak;
  }

  @override
  void didUpdateWidget(covariant StreakBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.feedbackState.pending) {
      return;
    }
    if (oldWidget.feedbackState.pending &&
        !widget.feedbackState.pending &&
        oldWidget.feedbackState.epoch != widget.feedbackState.epoch) {
      _timer?.cancel();
      _timer = Timer(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _visible = widget.streak;
          });
        }
      });
      return;
    }
    if (oldWidget.streak == widget.streak) {
      return;
    }
    _setImmediate(widget.streak);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppDurations.short,
      child: Text(
        'Day $_visible',
        key: ValueKey(_visible),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
      ),
    );
  }

  void _setImmediate(int streak) {
    _timer?.cancel();
    setState(() {
      _visible = streak;
    });
  }
}
