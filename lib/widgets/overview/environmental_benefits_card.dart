import 'package:flutter/material.dart';
import '../../../models/environmental_data.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

class EnvironmentalBenefitsCard extends StatelessWidget {
  final EnvironmentalData? data;

  const EnvironmentalBenefitsCard({
    super.key,
    this.data,
  });

  @override
  Widget build(BuildContext context) {
    final envData = data ?? EnvironmentalData.demo();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.success.withValues(alpha: 0.15),
            AppColors.primary.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.eco_rounded,
                color: AppColors.success,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Environmental Benefits',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _BenefitItem(
                icon: '🌳',
                label: 'Trees Planted',
                value: envData.treeEquivalent.toStringAsFixed(2),
              ),
              _BenefitItem(
                icon: '☁️',
                label: 'CO2 Saved',
                value: '${envData.co2Saved.toStringAsFixed(2)} kg',
              ),
              _BenefitItem(
                icon: '💧',
                label: 'Water Saved',
                value: '${envData.waterSaved.toStringAsFixed(1)} L',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.local_gas_station_rounded,
                    color: AppColors.success, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Fuel Saved: ${envData.fuelSaved.toStringAsFixed(2)} liters',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitItem extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _BenefitItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          icon,
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.success,
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
