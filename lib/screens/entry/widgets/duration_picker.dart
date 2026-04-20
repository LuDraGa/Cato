import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../../../app/theme.dart';

class DurationPicker extends StatefulWidget {
  const DurationPicker({
    super.key,
    required this.minutes,
    required this.onChanged,
  });

  final int minutes;
  final ValueChanged<int> onChanged;

  @override
  State<DurationPicker> createState() => _DurationPickerState();
}

class _DurationPickerState extends State<DurationPicker> {
  late FixedExtentScrollController _hoursController;
  late FixedExtentScrollController _minutesController;
  late int _hours;
  late int _mins;

  @override
  void initState() {
    super.initState();
    _hours = widget.minutes ~/ 60;
    _mins = widget.minutes % 60;
    _hoursController = FixedExtentScrollController(initialItem: _hours);
    _minutesController = FixedExtentScrollController(initialItem: _mins);
  }

  @override
  void didUpdateWidget(covariant DurationPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newHours = widget.minutes ~/ 60;
    final newMins = widget.minutes % 60;
    // Only sync for truly external changes (e.g. "Same as yesterday").
    // Our own _emit already updated _hours/_mins before calling onChanged,
    // so this condition is false for self-triggered rebuilds.
    if (newHours != _hours || newMins != _mins) {
      _hours = newHours;
      _mins = newMins;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_hoursController.selectedItem % 24 != _hours) {
          _hoursController.jumpToItem(_hours);
        }
        if (_minutesController.selectedItem % 60 != _mins) {
          _minutesController.jumpToItem(_mins);
        }
      });
    }
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  void _emit({int? hours, int? minutes}) {
    // Update local state BEFORE calling onChanged so concurrent
    // _emit calls from the other wheel read the latest value.
    if (hours != null) _hours = hours;
    if (minutes != null) _mins = minutes;
    widget.onChanged((_hours * 60) + _mins);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _wheel(
              controller: _hoursController,
              count: 24,
              suffix: 'h',
              onSelectedItemChanged: (value) => _emit(hours: value),
            ),
          ),
          Expanded(
            child: _wheel(
              controller: _minutesController,
              count: 60,
              suffix: 'm',
              onSelectedItemChanged: (value) => _emit(minutes: value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _wheel({
    required FixedExtentScrollController controller,
    required int count,
    required String suffix,
    required ValueChanged<int> onSelectedItemChanged,
  }) {
    return Stack(
      children: [
        IgnorePointer(
          child: Center(
            child: Container(
              height: 36,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: AppColors.sage.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        ListWheelScrollView.useDelegate(
          controller: controller,
          itemExtent: 36,
          perspective: 0.003,
          overAndUnderCenterOpacity: 0.35,
          physics: const _RoulettePhysics(),
          onSelectedItemChanged: onSelectedItemChanged,
          childDelegate: ListWheelChildLoopingListDelegate(
            children: List.generate(count, (index) {
              return Center(
                child: Text(
                  '${index.toString().padLeft(2, '0')} $suffix',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

/// Scroll physics that coast with friction then spring-snap to nearest item.
class _RoulettePhysics extends ScrollPhysics {
  const _RoulettePhysics({super.parent});

  @override
  _RoulettePhysics applyTo(ScrollPhysics? ancestor) {
    return _RoulettePhysics(parent: buildParent(ancestor));
  }

  // Slightly underdamped spring (ratio ~0.64) for visible overshoot on snap.
  static const _spring = SpringDescription(mass: 1, stiffness: 120, damping: 14);

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    const itemExtent = 36.0;
    final nearest = (position.pixels / itemExtent).round() * itemExtent;

    if (velocity.abs() < 80) {
      // Slow release — spring directly to nearest item.
      if ((position.pixels - nearest).abs() < 0.5) return null;
      return SpringSimulation(_spring, position.pixels, nearest, velocity);
    }

    // Fast fling — coast with friction, then spring-snap.
    return _CoastSnapSimulation(
      position: position.pixels,
      velocity: velocity,
      itemExtent: itemExtent,
      spring: _spring,
    );
  }
}

/// Friction deceleration that transitions into a spring snap once slow enough.
class _CoastSnapSimulation extends Simulation {
  _CoastSnapSimulation({
    required double position,
    required double velocity,
    required double itemExtent,
    required SpringDescription spring,
  }) : _friction = FrictionSimulation(0.135, position, velocity) {
    const snapThreshold = 60.0;
    _switchTime =
        math.log(snapThreshold / velocity.abs()) / math.log(0.135);

    final switchPos = _friction.x(_switchTime);
    final switchVel = _friction.dx(_switchTime);
    final nearest = (switchPos / itemExtent).round() * itemExtent;
    _snap = SpringSimulation(spring, switchPos, nearest, switchVel);
  }

  final FrictionSimulation _friction;
  late final double _switchTime;
  late final SpringSimulation _snap;

  @override
  double x(double time) {
    if (time < _switchTime) return _friction.x(time);
    return _snap.x(time - _switchTime);
  }

  @override
  double dx(double time) {
    if (time < _switchTime) return _friction.dx(time);
    return _snap.dx(time - _switchTime);
  }

  @override
  bool isDone(double time) {
    if (time < _switchTime) return false;
    return _snap.isDone(time - _switchTime);
  }
}
