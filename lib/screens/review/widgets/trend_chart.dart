import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../models/tracker.dart';
import '../../../providers/review_providers.dart';

/// Inline trend chart with smooth sparklines.
/// Shows the current tracker + any comparison trackers as overlaid curves.
class TrendChart extends ConsumerWidget {
  const TrendChart({
    super.key,
    required this.primaryTracker,
    required this.periodStart,
    required this.periodEnd,
  });

  final Tracker primaryTracker;
  final DateTime periodStart;
  final DateTime periodEnd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comparisonUids = ref.watch(reviewComparisonUidsProvider);
    final allTrackers = ref.watch(reviewTrackersProvider);
    final allUids = <String>[
      primaryTracker.uid,
      ...comparisonUids.where((uid) => uid != primaryTracker.uid),
    ];

    final trendData = ref.watch(trendDataProvider(TrendRequest(
      trackerUids: allUids,
      start: periodStart,
      end: periodEnd,
    )));

    if (trendData.isEmpty) return const SizedBox.shrink();

    // Comparison tracker toggle chips
    final otherTrackers =
        allTrackers.where((t) => t.uid != primaryTracker.uid).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            'Trends',
            style: AppTextStyles.title(AppColors.inkBlack).copyWith(fontSize: 16),
          ),
        ),
        if (otherTrackers.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 32,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: otherTrackers.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                final t = otherTrackers[index];
                final selected = comparisonUids.contains(t.uid);
                final color = _lineColorForIndex(
                  allUids.indexOf(t.uid) == -1
                      ? index + 1
                      : allUids.indexOf(t.uid),
                );
                return GestureDetector(
                  onTap: () {
                    final current =
                        Set<String>.from(ref.read(reviewComparisonUidsProvider));
                    if (selected) {
                      current.remove(t.uid);
                    } else if (current.length < 3) {
                      current.add(t.uid);
                    }
                    ref.read(reviewComparisonUidsProvider.notifier).state =
                        current;
                  },
                  child: AnimatedContainer(
                    duration: AppDurations.short,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? color.withValues(alpha: 0.12)
                          : AppColors.bgSurface,
                      borderRadius: BorderRadius.circular(999),
                      border: selected
                          ? Border.all(color: color.withValues(alpha: 0.4))
                          : Border.all(
                              color: AppColors.inkBlack.withValues(alpha: 0.04)),
                    ),
                    child: Text(
                      '${t.icon} ${t.name}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: selected ? color : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.inkBlack.withValues(alpha: 0.04),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: CustomPaint(
              size: const Size(double.infinity, double.infinity),
              painter: _TrendPainter(lines: trendData),
            ),
          ),
        ),
        // Legend
        if (trendData.length > 1) ...[
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Wrap(
              spacing: AppSpacing.md,
              runSpacing: 4,
              children: trendData.asMap().entries.map((entry) {
                final color = _lineColorForIndex(entry.key);
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: 12,
                      height: 3,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      entry.value.trackerName,
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }
}

Color _lineColorForIndex(int index) {
  final palette = <Color>[
    AppColors.sage,
    AppColors.fitness,
    AppColors.rest,
    AppColors.mind,
    AppColors.vices,
    AppColors.nutrition,
  ];
  return palette[index % palette.length];
}

class _TrendPainter extends CustomPainter {
  const _TrendPainter({required this.lines});

  final List<TrendLine> lines;

  @override
  void paint(Canvas canvas, Size size) {
    if (lines.isEmpty) return;

    // Draw baseline
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      Paint()
        ..color = AppColors.inkBlack.withValues(alpha: 0.04)
        ..strokeWidth = 0.5,
    );

    // Draw mid-line
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      Paint()
        ..color = AppColors.inkBlack.withValues(alpha: 0.03)
        ..strokeWidth = 0.5,
    );

    for (var lineIndex = 0; lineIndex < lines.length; lineIndex++) {
      final line = lines[lineIndex];
      final color = _lineColorForIndex(lineIndex);
      final validPoints = <_PlotPoint>[];

      for (var i = 0; i < line.points.length; i++) {
        final p = line.points[i];
        if (p.value == null) continue;
        final x = line.points.length <= 1
            ? size.width / 2
            : (i / (line.points.length - 1)) * size.width;
        final y = size.height - (p.value! * size.height);
        validPoints.add(_PlotPoint(x, y));
      }

      if (validPoints.length < 2) continue;

      // Smooth cubic bezier path ("drawn, not rendered")
      final path = Path();
      path.moveTo(validPoints.first.x, validPoints.first.y);
      for (var i = 1; i < validPoints.length; i++) {
        final prev = validPoints[i - 1];
        final curr = validPoints[i];
        final cpx = (prev.x + curr.x) / 2;
        path.cubicTo(cpx, prev.y, cpx, curr.y, curr.x, curr.y);
      }

      // Fill gradient under the primary line
      if (lineIndex == 0) {
        final fillPath = Path.from(path);
        fillPath.lineTo(validPoints.last.x, size.height);
        fillPath.lineTo(validPoints.first.x, size.height);
        fillPath.close();
        canvas.drawPath(
          fillPath,
          Paint()
            ..shader = ui.Gradient.linear(
              Offset(0, 0),
              Offset(0, size.height),
              [
                color.withValues(alpha: 0.12),
                color.withValues(alpha: 0.0),
              ],
            ),
        );
      }

      // Draw the line
      canvas.drawPath(
        path,
        Paint()
          ..color = color.withValues(alpha: lineIndex == 0 ? 0.8 : 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = lineIndex == 0 ? 2.0 : 1.5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..isAntiAlias = true,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) {
    return oldDelegate.lines != lines;
  }
}

class _PlotPoint {
  const _PlotPoint(this.x, this.y);
  final double x;
  final double y;
}
