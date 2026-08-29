import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/app_constants.dart';
import '../../models/energy_reading.dart';
import 'energy_flow_painter.dart';
import 'energy_node.dart';

final _solarColor = AppColors.warning;
final _gridColor = AppColors.info;
const _homeColor = Color(0xFF7C4DFF);
final _batteryColor = AppColors.success;
final _inverterColor = AppColors.primary;

// Circle sizes
const _nodeR = 36.0; // outer node radius  (diameter 72)
const _centerR = 44.0; // inverter radius     (diameter 88)
const _labelH = 34.0; // height of 2-line label block

// The gap (in px) between any outer circle edge and the inverter circle edge
// — same on all 4 arms so spacing looks uniform
const _armGap = 60.0;

// Derived vertical sizes
const _nodeD = _nodeR * 2;
const _centerD = _centerR * 2;

// Total canvas height:
// [label above solar] + [solar circle] + [armGap] + [inverter circle] + [armGap] + [battery circle] + [label below battery]
const _totalH =
    _labelH + _nodeD + _armGap + _centerD + _armGap + _nodeD + _labelH;

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
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _fmtW(double w) => w >= 1000
      ? '${(w / 1000).toStringAsFixed(2)} kW'
      : '${w.toStringAsFixed(0)} W';

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
          // Header
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
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Live',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingMD),

          // Cross diagram
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => SizedBox(
              height: _totalH,
              child: LayoutBuilder(
                builder: (_, constraints) {
                  final w = constraints.maxWidth;
                  final cx = w / 2;

                  // ── Vertical centers ──
                  // Solar:   label is ABOVE circle → circle top = _labelH
                  final solarCY = _labelH + _nodeR;
                  // Inverter sits exactly _armGap below solar circle edge
                  final invCY = solarCY + _nodeR + _armGap + _centerR;
                  // Battery: exactly _armGap below inverter circle edge
                  final batteryCY = invCY + _centerR + _armGap + _nodeR;

                  // ── Horizontal centers ──
                  // Grid/Home are vertically aligned with inverter center.
                  // Their horizontal position: inverter edge + _armGap + nodeR
                  final gridCX = cx - _centerR - _armGap - _nodeR;
                  final homeCX = cx + _centerR + _armGap + _nodeR;

                  final solarCenter = Offset(cx, solarCY);
                  final inverterCenter = Offset(cx, invCY);
                  final batteryCenter = Offset(cx, batteryCY);
                  final gridCenter = Offset(gridCX, invCY);
                  final homeCenter = Offset(homeCX, invCY);

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Lines — drawn behind nodes
                      Positioned.fill(
                        child: CustomPaint(
                          painter: EnergyFlowPainter(
                            animValue: _ctrl.value,
                            canvasW: w,
                            canvasH: _totalH,
                            solarCenter: solarCenter,
                            gridCenter: gridCenter,
                            homeCenter: homeCenter,
                            batteryCenter: batteryCenter,
                            inverterCenter: inverterCenter,
                            solarColor: _solarColor,
                            gridColor: _gridColor,
                            homeColor: _homeColor,
                            batteryColor: _batteryColor,
                            solarActive: r.solarPowerW > 0,
                            gridActive: r.gridPowerW.abs() > 0,
                            homeActive: r.consumptionPowerW > 0,
                            batteryActive: r.batteryPowerW.abs() > 0,
                          ),
                        ),
                      ),

                      // Solar — label ABOVE circle
                      Positioned(
                        top: 0,
                        left: cx - _nodeR,
                        child: EnergyNode(
                          icon: Icons.wb_sunny_rounded,
                          label: 'Solar Power',
                          value: _fmtW(r.solarPowerW),
                          color: _solarColor,
                          labelOnTop: true,
                        ),
                      ),

                      // Grid — left, circle center at (gridCX, invCY)
                      Positioned(
                        top: invCY - _nodeR,
                        left: gridCX - _nodeR,
                        child: EnergyNode(
                          icon: Icons.cell_tower_rounded,
                          label: 'Grid',
                          value: '${r.gridPowerW.abs().toStringAsFixed(1)} V',
                          color: _gridColor,
                        ),
                      ),

                      // Home — right, circle center at (homeCX, invCY)
                      Positioned(
                        top: invCY - _nodeR,
                        left: homeCX - _nodeR,
                        child: EnergyNode(
                          icon: Icons.home_rounded,
                          label: 'Home',
                          value: _fmtW(r.consumptionPowerW),
                          color: _homeColor,
                        ),
                      ),

                      // Battery — label BELOW circle
                      Positioned(
                        top: batteryCY - _nodeR,
                        left: cx - _nodeR,
                        child: EnergyNode(
                          icon: r.batteryCharging
                              ? Icons.battery_charging_full_rounded
                              : Icons.battery_std_rounded,
                          label: r.batteryCharging ? 'Charging' : 'Battery',
                          value: '${r.batteryPercent.toStringAsFixed(0)}%',
                          color: _batteryColor,
                        ),
                      ),

                      // Inverter — dead center
                      Positioned(
                        top: invCY - _centerR,
                        left: cx - _centerR,
                        child: EnergyNode(
                          icon: Icons.sync_alt_rounded,
                          label: 'Inverter',
                          value: _fmtW(r.solarPowerW),
                          color: _inverterColor,
                          isCenter: true,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
