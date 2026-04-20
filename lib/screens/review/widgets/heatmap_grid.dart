import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/date_utils.dart';
import '../../../app/theme.dart';
import '../../../models/tracker.dart';

class HeatmapGrid extends StatelessWidget {
  const HeatmapGrid({
    super.key,
    required this.tracker,
    required this.month,
    required this.data,
    required this.onTap,
  });

  final Tracker tracker;
  final DateTime month;
  final Map<DateTime, double?> data;
  final ValueChanged<DateTime> onTap;

  @override
  Widget build(BuildContext context) {
    final monthStart = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leading = (monthStart.weekday + 6) % 7;
    final totalCells = leading + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final layout = _HeatmapLayout(
                  tracker: tracker,
                  month: month,
                  data: data,
                  width: constraints.maxWidth,
                  daysInMonth: daysInMonth,
                  leading: leading,
                  rows: rows,
                );

                return Column(
                  children: <Widget>[
                    const Row(
                      children: <Widget>[
                        _DayLabel('Mo'),
                        _DayLabel('Tu'),
                        _DayLabel('We'),
                        _DayLabel('Th'),
                        _DayLabel('Fr'),
                        _DayLabel('Sa'),
                        _DayLabel('Su'),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SizedBox(
                      width: layout.gridWidth,
                      height: layout.gridHeight,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTapUp: (details) {
                          final date = layout.dateAt(details.localPosition);
                          if (date != null) {
                            onTap(date);
                          }
                        },
                        child: CustomPaint(
                          painter: _HeatmapPainter(
                            cells: layout.cells,
                            gridSize: Size(layout.gridWidth, layout.gridHeight),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _NoisePainter()),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeatmapPainter extends CustomPainter {
  const _HeatmapPainter({
    required this.cells,
    required this.gridSize,
  });

  final List<_HeatmapCell> cells;
  final Size gridSize;

  @override
  void paint(Canvas canvas, Size size) {
    for (final cell in cells) {
      final rrect = RRect.fromRectAndRadius(
        cell.rect,
        Radius.circular(cell.radius),
      );
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = cell.color
          ..isAntiAlias = true,
      );

      final strokeRect = cell.filled ? cell.rect.deflate(0.6) : cell.rect;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          strokeRect,
          Radius.circular(
            math.max(0, cell.radius - (cell.filled ? 0.6 : 0)),
          ),
        ),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = cell.filled
              ? AppColors.inkBlack.withValues(alpha: 0.045)
              : AppColors.inkBlack.withValues(alpha: 0.055)
          ..isAntiAlias = true,
      );

      if (!cell.filled) {
        _paintDayNumber(canvas, cell);
        continue;
      }

      canvas.save();
      canvas.clipRRect(rrect);
      canvas.drawRect(
        cell.rect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Colors.white.withValues(alpha: 0.05),
              Colors.transparent,
              AppColors.inkBlack.withValues(alpha: 0.025),
            ],
            stops: const <double>[0, 0.52, 1],
          ).createShader(cell.rect)
          ..isAntiAlias = true,
      );
      canvas.restore();
      _paintDayNumber(canvas, cell);
    }
  }

  void _paintDayNumber(Canvas canvas, _HeatmapCell cell) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${cell.date.day}',
        style: TextStyle(
          fontSize: math.min(10.5, math.max(8.5, cell.rect.width * 0.24)),
          fontWeight: FontWeight.w500,
          color: cell.filled
              ? _dayNumberColor(cell.value)
              : AppColors.textTertiary.withValues(alpha: 0.72),
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        cell.rect.left + math.min(4, cell.rect.width * 0.14),
        cell.rect.top + math.min(4, cell.rect.height * 0.12),
      ),
    );
  }

  Color _dayNumberColor(double? value) {
    if (value != null && value >= 0.55) {
      return AppColors.bgElevated.withValues(alpha: 0.88);
    }
    return AppColors.inkBlack.withValues(alpha: 0.44);
  }

  @override
  bool shouldRepaint(covariant _HeatmapPainter oldDelegate) {
    return oldDelegate.cells != cells || oldDelegate.gridSize != gridSize;
  }
}

class _HeatmapLayout {
  _HeatmapLayout({
    required Tracker tracker,
    required DateTime month,
    required Map<DateTime, double?> data,
    required double width,
    required int daysInMonth,
    required int leading,
    required int rows,
  })  : _month = month,
        _daysInMonth = daysInMonth,
        _leading = leading,
        _rows = rows,
        cellSize = (width - (_gap * 6)) / 7,
        gridWidth = width,
        gridHeight = rows * ((width - (_gap * 6)) / 7) + ((rows - 1) * _gap),
        cells = List<_HeatmapCell>.generate(daysInMonth, (index) {
          final dayNumber = index + 1;
          final cellIndex = leading + index;
          final row = cellIndex ~/ 7;
          final column = cellIndex % 7;
          final rect = Rect.fromLTWH(
            column * (((width - (_gap * 6)) / 7) + _gap),
            row * (((width - (_gap * 6)) / 7) + _gap),
            (width - (_gap * 6)) / 7,
            (width - (_gap * 6)) / 7,
          );
          final date = normalizeDate(DateTime(month.year, month.month, dayNumber));
          final value = data[date];
          return _HeatmapCell(
            date: date,
            rect: rect,
            radius: 5.5 + ((dayNumber * 37) % 11) / 10,
            color: _colorFor(tracker, value),
            filled: value != null,
            value: value,
          );
        });

  static const double _gap = 8;

  final DateTime _month;
  final int _daysInMonth;
  final int _leading;
  final int _rows;
  final double cellSize;
  final double gridWidth;
  final double gridHeight;
  final List<_HeatmapCell> cells;

  DateTime? dateAt(Offset position) {
    if (position.dx < 0 ||
        position.dy < 0 ||
        position.dx > gridWidth ||
        position.dy > gridHeight) {
      return null;
    }

    final column = position.dx ~/ (cellSize + _gap);
    final row = position.dy ~/ (cellSize + _gap);
    if (column > 6 || row >= _rows) {
      return null;
    }

    final localX = position.dx - (column * (cellSize + _gap));
    final localY = position.dy - (row * (cellSize + _gap));
    if (localX > cellSize || localY > cellSize) {
      return null;
    }

    final index = row * 7 + column;
    final dayNumber = index - _leading + 1;
    if (dayNumber <= 0 || dayNumber > _daysInMonth) {
      return null;
    }
    return normalizeDate(DateTime(_month.year, _month.month, dayNumber));
  }

  static Color _colorFor(Tracker tracker, double? value) {
    if (value == null) {
      return AppColors.heatNoData;
    }
    if (tracker.heatmapMode == 'presence') {
      return AppColors.sage;
    }
    if (value <= 0.10) {
      return AppColors.heatMinimal;
    }
    if (value <= 0.30) {
      return AppColors.heatLow;
    }
    if (value <= 0.55) {
      return AppColors.heatMid;
    }
    if (value <= 0.75) {
      return AppColors.heatHigh;
    }
    if (value <= 0.92) {
      return AppColors.heatStrong;
    }
    return AppColors.heatPeak;
  }
}

class _HeatmapCell {
  const _HeatmapCell({
    required this.date,
    required this.rect,
    required this.radius,
    required this.color,
    required this.filled,
    required this.value,
  });

  final DateTime date;
  final Rect rect;
  final double radius;
  final Color color;
  final bool filled;
  final double? value;

  @override
  bool operator ==(Object other) {
    return other is _HeatmapCell &&
        other.date == date &&
        other.rect == rect &&
        other.radius == radius &&
        other.color == color &&
        other.filled == filled &&
        other.value == value;
  }

  @override
  int get hashCode => Object.hash(date, rect, radius, color, filled, value);
}

class _DayLabel extends StatelessWidget {
  const _DayLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
      ),
    );
  }
}

class _NoisePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.inkBlack.withValues(alpha: 0.018)
      ..style = PaintingStyle.fill;
    final random = math.Random(size.width.floor() + size.height.floor());
    final count = (size.width * size.height * 0.012).round();
    for (var index = 0; index < count; index++) {
      final dx = random.nextDouble() * size.width;
      final dy = random.nextDouble() * size.height;
      canvas.drawRect(Rect.fromLTWH(dx, dy, 1, 1), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
