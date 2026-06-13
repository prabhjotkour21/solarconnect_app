import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/app_constants.dart';
import '../../models/energy_reading.dart';
import 'energy_flow_painter.dart';
import 'energy_node.dart';

// Node colors — single source of truth so painter & nodes always match
const _solarColor    = AppColors.warning;        // amber
const _gridColor     = AppColors.info;            // blue
const _homeColor     = Color(0xFF7C4DFF);         // purple
const _batteryColor  = AppColors.success;         // green
const _inverterColor = AppColors.primary;         // teal

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
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat();
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

    // Node layout constants
    const nodeSize    = 72.0;   // outer node diameter
    const centerSize  = 88.0;   // center inverter diameter
    const nodeLabelH  = 36.0;   // approx height of label+value text below icon
    const totalH      = nodeSize + nodeLabelH + 20 + centerSize + 20 + nodeSize + nodeLabelH;
    // totalH ≈ top-node + gap + center + gap + bottom-node

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
          // Header row
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
                      width: 6, height: 6,
                      decoration: const BoxDecoration(
                          color: AppColors.success, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 4),
                    Text('Live',
                        style: AppTextStyles.labelSmall
                            .copyWith(color: AppColors.success)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingMD),

          // ── Cross / plus layout ──────────────────────────────────────────
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) {
              return SizedBox(
                height: totalH,
                child: LayoutBuilder(
                  builder: (ctx, constraints) {
                    final w = constraints.maxWidth;
                    final h = totalH;

                    // Center of the whole cross area
                    final cx = w / 2;
                    final cy = h / 2;

                    // Node centers (icon center, not including label text)
                    final solarCenter   = Offset(cx,                     nodeSize / 2);
                    final batteryCenter = Offset(cx,                     h - nodeSize / 2);
                    final gridCenter    = Offset(nodeSize / 2,           cy);
                    final homeCenter    = Offset(w - nodeSize / 2,       cy);
                    final inverterCenter = Offset(cx, cy);

                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // ── Animated lines (painted behind nodes) ──
                        Positioned.fill(
                          child: CustomPaint(
                            painter: EnergyFlowPainter(
                              animValue:     _ctrl.value,
                              canvasW:       w,
                              canvasH:       h,
                              solarCenter:   solarCenter,
                              gridCenter:    gridCenter,
                              homeCenter:    homeCenter,
                              batteryCenter: batteryCenter,
                              inverterCenter: inverterCenter,
                              solarColor:    _solarColor,
                              gridColor:     _gridColor,
                              homeColor:     _homeColor,
                              batteryColor:  _batteryColor,
                              solarActive:   r.solarPowerW > 0,
                              gridActive:    r.gridPowerW.abs() > 0,
                              homeActive:    r.consumptionPowerW > 0,
                              batteryActive: r.batteryPowerW.abs() > 0,
                            ),
                          ),
                        ),

                        // ── Solar — top center ──
                        Positioned(
                          top: 0,
                          left: cx - nodeSize / 2,
                          child: EnergyNode(
                            icon: Icons.wb_sunny_rounded,
                            label: 'Solar Power',
                            value: _fmtW(r.solarPowerW),
                            color: _solarColor,
                          ),
                        ),

                        // ── Grid — left center ──
                        Positioned(
                          top: cy - nodeSize / 2,
                          left: 0,
                          child: EnergyNode(
                            icon: Icons.cell_tower_rounded,
                            label: 'Grid',
                            value: '${r.gridPowerW.abs().toStringAsFixed(1)} V',
                            color: _gridColor,
                          ),
                        ),

                        // ── Home — right center ──
                        Positioned(
                          top: cy - nodeSize / 2,
                          right: 0,
                          child: EnergyNode(
                            icon: Icons.home_rounded,
                            label: 'Home',
                            value: _fmtW(r.consumptionPowerW),
                            color: _homeColor,
                          ),
                        ),

                        // ── Battery — bottom center ──
                        Positioned(
                          bottom: 0,
                          left: cx - nodeSize / 2,
                          child: EnergyNode(
                            icon: r.batteryCharging
                                ? Icons.battery_charging_full_rounded
                                : Icons.battery_std_rounded,
                            label: r.batteryCharging ? 'Charging' : 'Battery',
                            value: '${r.batteryPercent.toStringAsFixed(0)}%',
                            color: _batteryColor,
                          ),
                        ),

                        // ── Inverter — dead center ──
                        Positioned(
                          top: cy - centerSize / 2,
                          left: cx - centerSize / 2,
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
              );
            },
          ),
        ],
      ),
    );
  }
}
