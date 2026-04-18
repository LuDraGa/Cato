import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

  int get _hours => widget.minutes ~/ 60;
  int get _minutes => widget.minutes % 60;

  @override
  void initState() {
    super.initState();
    _hoursController = FixedExtentScrollController(initialItem: _hours);
    _minutesController = FixedExtentScrollController(initialItem: _minutes);
  }

  @override
  void didUpdateWidget(covariant DurationPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.minutes != widget.minutes) {
      _hoursController.jumpToItem(_hours);
      _minutesController.jumpToItem(_minutes);
    }
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  void _emit({int? hours, int? minutes}) {
    widget.onChanged(((hours ?? _hours) * 60) + (minutes ?? _minutes));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(18),
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
    return CupertinoPicker.builder(
      scrollController: controller,
      itemExtent: 36,
      useMagnifier: true,
      magnification: 1.05,
      selectionOverlay: const SizedBox.shrink(),
      onSelectedItemChanged: onSelectedItemChanged,
      childCount: count,
      itemBuilder: (context, index) {
        return Center(
          child: Text(
            '${index.toString().padLeft(2, '0')} $suffix',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        );
      },
    );
  }
}

