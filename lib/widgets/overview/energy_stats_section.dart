import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/app_constants.dart';
import '../../models/energy_reading.dart';
import '../common/summary_card.dart';

class EnergyStatsSection extends StatelessWidget {
  final EnergyReading reading;
  const EnergyStatsSection({super.key, required this.reading});

  @override
  Widget build(BuildContext context) {
    final r = reading;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Today's Stats", style: AppTextStyles.headingSmall),
          const SizedBox(height: AppConstants.paddingSM),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: AppConstants.paddingSM,
            mainAxisSpacing: AppConstants.paddingSM,
            childAspectRatio: 1.55,
            children: [
              SummaryCard(
                label: "Today's Generation",
                value: r.solarTodayKwh.toStringAsFixed(1),
                unit: 'kWh',
                icon: Icons.wb_sunny_rounded,
                iconColor: AppColors.warning,
              ),
              SummaryCard(
                label: 'Consumption',
                value: r.consumptionTodayKwh.toStringAsFixed(1),
                unit: 'kWh',
                icon: Icons.home_rounded,
                iconColor: AppColors.primaryLight,
              ),
              SummaryCard(
                label: 'Grid Export',
                value: r.gridExportTodayKwh.toStringAsFixed(1),
                unit: 'kWh',
                icon: Icons.upload_rounded,
                iconColor: AppColors.info,
              ),
              SummaryCard(
                label: 'Grid Import',
                value: r.gridImportTodayKwh.toStringAsFixed(1),
                unit: 'kWh',
                icon: Icons.download_rounded,
                iconColor: AppColors.error,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
