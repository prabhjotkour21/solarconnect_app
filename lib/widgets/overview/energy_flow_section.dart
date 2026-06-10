import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/app_constants.dart';
import '../../models/energy_reading.dart';
import 'energy_flow_painter.dart';
import 'energy_node.dart';

class EnergyFlowSection extends StatefulWidget {
  final EnergyReading reading;
  const EnergyFlowSection({super.key, required this.reading});

  @override
  State<EnergyFlowSection> createState() => _EnergyFlowSectionState();
}

class _EnergyFlowSectionState extends State<EnergyFlowSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _fmtW(double w) =>
      w >= 1000 ? '${(w / 1000).toStringAsFixed(1)} kW' : '${w.toStringAsFixed(0)} W';

  @override
  Widget build(BuildContext context) {
    final r = widget.reading;
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Energy Flow', style: AppTextStyles.headingSmall),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text('Live', style: AppTextStyles.labelSmall.copyWith(color: AppColors.success)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingMD),
          SizedBox(
            height: 260,
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) => Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: EnergyFlowPainter(
                        animValue: _ctrl.value,
                        solarActive: r.solarPowerW > 0,
                        gridActive: r.gridPowerW.abs() > 0,
                        homeActive: r.consumptionPowerW > 0,
                        batteryActive: r.batteryPowerW.abs() > 0,
                      ),
                    ),
                  ),
                  // Top-left: Solar
                  Positioned(
                    top: 0,
                    left: 0,
                    child: EnergyNode(
                      icon: Icons.wb_sunny_rounded,
                      label: 'Solar',
                      value: _fmtW(r.solarPowerW),
                      color: AppColors.warning,
                    ),
                  ),
                  // Top-right: Grid
                  Positioned(
                    top: 0,
                    right: 0,
                    child: EnergyNode(
                      icon: Icons.electric_bolt_rounded,
                      label: 'Grid',
                      value: _fmtW(r.gridPowerW.abs()),
                      color: AppColors.info,
                    ),
                  ),
                  // Center: Inverter
                  Positioned.fill(
                    child: Center(
                      child: EnergyNode(
                        icon: Icons.sync_alt_rounded,
                        label: 'Inverter',
                        value: _fmtW(r.solarPowerW),
                        color: AppColors.primary,
                        isCenter: true,
                      ),
                    ),
                  ),
                  // Bottom-left: Battery
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: EnergyNode(
                      icon: r.batteryCharging
                          ? Icons.battery_charging_full_rounded
                          : Icons.battery_std_rounded,
                      label: 'Battery',
                      value: '${r.batteryPercent.toStringAsFixed(0)}%',
                      color: AppColors.success,
                    ),
                  ),
                  // Bottom-right: Home
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: EnergyNode(
                      icon: Icons.home_rounded,
                      label: 'Home',
                      value: _fmtW(r.consumptionPowerW),
                      color: AppColors.primaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
