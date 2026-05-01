import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../providers/review_providers.dart';

/// DEMO: Multi-tracker summary view.
/// Compact dashboard showing all trackers at a glance with mini sparklines.
class MultiTrackerSummary extends ConsumerWidget {
  const MultiTrackerSummary({super.key, required this.onSelectTracker});

  final ValueChanged<String> onSelectTracker;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(multiTrackerSummaryProvider);

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: <Widget>[
              Text(
                'All Trackers',
                style: AppTextStyles.title(
                  AppColors.inkBlack,
                ).copyWith(fontSize: 18),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.fitness.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.fitness.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  'DEMO',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.fitness,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final item = items[index];
              return _TrackerRow(
                item: item,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onSelectTracker(item.tracker.uid);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TrackerRow extends StatelessWidget {
  const _TrackerRow({required this.item, required this.onTap});

  final TrackerSummaryItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.inkBlack.withValues(alpha: 0.04)),
        ),
        child: Row(
          children: <Widget>[
            // Icon + name
            Text(item.tracker.icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.tracker.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.inkBlack,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.streak}d streak \u00B7 ${(item.completionRate30d * 100).round()}%',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            // Mini sparkline (last 30 days)
            const SizedBox(width: AppSpacing.sm),
            SizedBox(
              width: 80,
              height: 28,
              child: CustomPaint(
                painter: _MiniSparklinePainter(values: item.last30Values),
              ),
            ),
            // Trend arrow
            const SizedBox(width: AppSpacing.sm),
            _TrendArrow(values: item.last30Values),
          ],
        ),
      ),
    );
  }
}

class _TrendArrow extends StatelessWidget {
  const _TrendArrow({required this.values});

  final List<double?> values;

  @override
  Widget build(BuildContext context) {
    final recent = values.length > 7
        ? values.sublist(values.length - 7)
        : values;
    final older = values.length > 14
        ? values.sublist(values.length - 14, values.length - 7)
        : values;

    final recentAvg = _avg(recent);
    final olderAvg = _avg(older);

    if (recentAvg == null || olderAvg == null) {
      return Icon(
        Icons.remove_rounded,
        size: 16,
        color: AppColors.textTertiary.withValues(alpha: 0.5),
      );
    }

    final diff = recentAvg - olderAvg;
    if (diff > 0.05) {
      return Icon(Icons.trending_up_rounded, size: 16, color: AppColors.sage);
    } else if (diff < -0.05) {
      return Icon(
        Icons.trending_down_rounded,
        size: 16,
        color: AppColors.vices,
      );
    }
    return Icon(
      Icons.trending_flat_rounded,
      size: 16,
      color: AppColors.textTertiary,
    );
  }

  double? _avg(List<double?> vals) {
    final valid = vals.whereType<double>().toList();
    if (valid.isEmpty) return null;
    return valid.reduce((a, b) => a + b) / valid.length;
  }
}

class _MiniSparklinePainter extends CustomPainter {
  const _MiniSparklinePainter({required this.values});

  final List<double?> values;

  @override
  void paint(Canvas canvas, Size size) {
    final points = <Offset>[];
    for (var i = 0; i < values.length; i++) {
      final v = values[i];
      if (v == null) continue;
      final x = values.length <= 1
          ? size.width / 2
          : (i / (values.length - 1)) * size.width;
      final y = size.height - (v * size.height * 0.85) - (size.height * 0.075);
      points.add(Offset(x, y));
    }

    if (points.length < 2) return;

    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final cpx = (prev.dx + curr.dx) / 2;
      path.cubicTo(cpx, prev.dy, cpx, curr.dy, curr.dx, curr.dy);
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.sage.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(covariant _MiniSparklinePainter oldDelegate) {
    return true; // values list identity changes
  }
}
