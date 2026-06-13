import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

class EconomicBenefitsCard extends StatelessWidget {
  /// Today's solar generation in kWh — used to compute all values
  final double solarTodayKwh;
  /// Total lifetime generation in kWh
  final double solarTotalKwh;

  const EconomicBenefitsCard({
    super.key,
    required this.solarTodayKwh,
    required this.solarTotalKwh,
  });

  // ── Calculation constants ──
  static const double _ratePerKwh   = 8.0;   // ₹ per kWh grid rate
  static const double _feedInRate   = 4.5;   // ₹ per kWh feed-in tariff
  static const double _investmentRs = 120000; // demo system cost in ₹

  double get _todaySavings   => solarTodayKwh * _ratePerKwh;
  double get _monthSavings   => _todaySavings * 30;
  double get _totalSavings   => solarTotalKwh * _ratePerKwh;
  double get _feedInEarnings => solarTotalKwh * _feedInRate * 0.4; // ~40% exported
  double get _roiPercent     => (_totalSavings / _investmentRs) * 100;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.15),
            AppColors.warning.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              Icon(Icons.currency_rupee_rounded,
                  color: AppColors.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                'Economic Benefits',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Top row — 3 stat tiles
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _EconItem(
                emoji: '📅',
                label: "Today's Saving",
                value: '₹${_todaySavings.toStringAsFixed(0)}',
                color: AppColors.success,
              ),
              _EconItem(
                emoji: '📆',
                label: 'Monthly Est.',
                value: '₹${_monthSavings.toStringAsFixed(0)}',
                color: AppColors.primary,
              ),
              _EconItem(
                emoji: '💰',
                label: 'Total Saved',
                value: '₹${_totalSavings.toStringAsFixed(0)}',
                color: AppColors.warning,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Feed-in earnings row
          _InfoRow(
            icon: Icons.upload_rounded,
            color: AppColors.info,
            text:
                'Feed-in Earnings: ₹${_feedInEarnings.toStringAsFixed(0)} (exported energy)',
          ),
          const SizedBox(height: 8),

          // ROI row
          _InfoRow(
            icon: Icons.trending_up_rounded,
            color: AppColors.primary,
            text:
                'Return on Investment: ${_roiPercent.toStringAsFixed(1)}% of ₹${(_investmentRs / 1000).toStringAsFixed(0)}k investment',
          ),
        ],
      ),
    );
  }
}

// ── Small stat tile ──────────────────────────────────────────────────────────
class _EconItem extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final Color color;

  const _EconItem({
    required this.emoji,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.labelLarge.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textSecondary,
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ── Info row with icon ───────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _InfoRow({
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
