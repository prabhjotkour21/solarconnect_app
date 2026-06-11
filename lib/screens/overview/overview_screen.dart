import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/energy_reading.dart';
import '../../models/environmental_data.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/app_constants.dart';
import '../../widgets/overview/energy_flow_section.dart';
import '../../widgets/overview/energy_stats_section.dart';
import '../../widgets/overview/battery_card.dart';
import '../../widgets/overview/environmental_benefits_card.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  EnergyReading _reading = EnergyReading.demo();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(AppConstants.mockRefreshInterval, (_) {
      if (mounted) setState(() => _reading = EnergyReading.demo());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 100,
            floating: true,
            snap: true,
            backgroundColor: AppColors.backgroundDark,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Good Morning ☀️',
                          style: AppTextStyles.bodySmall.copyWith(fontSize: 11)),
                      Text('SolarConnect',
                          style: AppTextStyles.headingMedium.copyWith(
                            color: AppColors.primary,
                            fontSize: 18,
                          )),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.wb_sunny_rounded, color: AppColors.warning, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${(_reading.solarPowerW / 1000).toStringAsFixed(1)} kW',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(bottom: AppConstants.paddingXL),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                EnergyFlowSection(reading: _reading),
                const SizedBox(height: AppConstants.paddingMD),
                EnergyStatsSection(reading: _reading),
                const SizedBox(height: AppConstants.paddingMD),
                BatteryCard(reading: _reading),
                const SizedBox(height: AppConstants.paddingMD),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMD),
                  child: EnvironmentalBenefitsCard(
                    data: EnvironmentalData.fromGeneration(_reading.solarTodayKwh),
                  ),
                ),
                const SizedBox(height: AppConstants.paddingMD),
                _AccumulatedCard(reading: _reading),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccumulatedCard extends StatelessWidget {
  final EnergyReading reading;
  const _AccumulatedCard({required this.reading});

  @override
  Widget build(BuildContext context) {
    // Mock accumulated (multiply today by ~30 for demo)
    final totalKwh = (reading.solarTodayKwh * 287).toStringAsFixed(0);
    final co2Saved = (reading.solarTodayKwh * 287 * 0.233).toStringAsFixed(0);
    final moneySaved = (reading.solarTodayKwh * 287 * 0.28).toStringAsFixed(0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMD),
      padding: const EdgeInsets.all(AppConstants.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Accumulated Generation', style: AppTextStyles.headingSmall),
          const SizedBox(height: AppConstants.paddingMD),
          Row(
            children: [
              _stat(Icons.bolt_rounded, '$totalKwh', 'kWh', 'Total Generated',
                  AppColors.warning),
              _divider(),
              _stat(Icons.eco_rounded, '$co2Saved', 'kg', 'CO₂ Saved',
                  AppColors.success),
              _divider(),
              _stat(Icons.savings_rounded, '\$$moneySaved', '', 'Savings',
                  AppColors.primary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 48,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: AppColors.divider,
      );

  Widget _stat(IconData icon, String value, String unit, String label, Color color) =>
      Expanded(
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: AppTextStyles.headingSmall.copyWith(color: color, fontSize: 15),
                  ),
                  if (unit.isNotEmpty)
                    TextSpan(
                      text: ' $unit',
                      style: AppTextStyles.labelSmall,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.labelSmall, textAlign: TextAlign.center),
          ],
        ),
      );
}
