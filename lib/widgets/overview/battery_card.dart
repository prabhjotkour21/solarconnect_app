import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/app_constants.dart';
import '../../models/energy_reading.dart';

class BatteryCard extends StatelessWidget {
  final EnergyReading reading;
  const BatteryCard({super.key, required this.reading});

  @override
  Widget build(BuildContext context) {
    final pct = reading.batteryPercent / 100;
    final color = pct > 0.5
        ? AppColors.success
        : pct > 0.2
            ? AppColors.warning
            : AppColors.error;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMD),
      padding: const EdgeInsets.all(AppConstants.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          CircularPercentIndicator(
            radius: 44,
            lineWidth: 8,
            percent: pct.clamp(0.0, 1.0),
            center: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${reading.batteryPercent.toStringAsFixed(0)}%',
                  style: AppTextStyles.headingMedium.copyWith(color: color),
                ),
                Icon(
                  reading.batteryCharging
                      ? Icons.battery_charging_full_rounded
                      : Icons.battery_std_rounded,
                  color: color,
                  size: 16,
                ),
              ],
            ),
            progressColor: color,
            backgroundColor: color.withValues(alpha: 0.15),
            circularStrokeCap: CircularStrokeCap.round,
          ),
          const SizedBox(width: AppConstants.paddingMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Battery Storage', style: AppTextStyles.headingSmall),
                const SizedBox(height: 4),
                Text(
                  reading.batteryCharging ? 'Charging' : 'Discharging',
                  style: AppTextStyles.bodySmall.copyWith(color: color),
                ),
                const SizedBox(height: 8),
                _row(Icons.bolt, '${reading.batteryPowerW.abs().toStringAsFixed(0)} W',
                    reading.batteryCharging ? 'Charge rate' : 'Discharge rate'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String value, String label) => Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(value, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary)),
          const SizedBox(width: 4),
          Text(label, style: AppTextStyles.bodySmall),
        ],
      );
}
