import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../providers/review_providers.dart';

class SummaryStats extends StatelessWidget {
  const SummaryStats({super.key, required this.summary});

  final PeriodSummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.inkBlack.withValues(alpha: 0.04),
        ),
      ),
      child: Row(
        children: <Widget>[
          _StatCell(
            label: 'Best Streak',
            value: '${summary.longestStreak}d',
          ),
          _divider(),
          _StatCell(
            label: 'Completion',
            value: '${(summary.completionRate * 100).round()}%',
          ),
          if (summary.averageScore != null) ...[
            _divider(),
            _StatCell(
              label: 'Avg',
              value: _formatScore(summary),
            ),
          ],
        ],
      ),
    );
  }

  String _formatScore(PeriodSummary summary) {
    final score = summary.averageScore!;
    final formatted =
        score == score.roundToDouble() ? '${score.round()}' : score.toStringAsFixed(1);
    if (summary.scoreMax != null && summary.scoreMax! > 0) {
      return '$formatted/${summary.scoreMax}';
    }
    return formatted;
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      color: AppColors.inkBlack.withValues(alpha: 0.06),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.inkBlack,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textTertiary,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
