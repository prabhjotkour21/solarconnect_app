import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/energy_reading.dart';
import '../../models/environmental_data.dart';
import '../../services/service_locator.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/app_constants.dart';
import '../../widgets/overview/energy_flow_section.dart';
import '../../widgets/overview/energy_stats_section.dart';
import '../../widgets/overview/battery_card.dart';
import '../../widgets/overview/environmental_benefits_card.dart';
import '../../widgets/overview/economic_benefits_card.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  EnergyReading _reading = EnergyReading.empty();
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _weeklySummary = [];
  Map<String, dynamic>? _dashboardMetrics;
  Map<String, dynamic>? _energyStatistics;
  Map<String, dynamic>? _dailySummary;
  Map<String, dynamic>? _inverterStatus;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    _connectSocket();
  }

  @override
  void dispose() {
    ServiceLocator.instance.socketService.disconnect();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    final token = await ServiceLocator.instance.authService.getStoredToken();
    if (token == null || token.isEmpty) {
      setState(() {
        _errorMessage = 'Authentication token not found. Please login again.';
        _isLoading = false;
      });
      return;
    }

    try {
      final overview = await ServiceLocator.instance.dashboardService
          .getOverview(token);
      final weeklySummary = await ServiceLocator.instance.dashboardService
          .getWeeklySummary(token);
      final metrics = await ServiceLocator.instance.dashboardService.getMetrics(
        token,
      );
      final dailySummary = await ServiceLocator.instance.energyService
          .getDailySummary(token);
      final statistics = await ServiceLocator.instance.energyService
          .getStatistics(token);

      setState(() {
        _reading = EnergyReading.fromDashboardOverview(overview);
        _weeklySummary = weeklySummary;
        _dashboardMetrics = metrics;
        _dailySummary = dailySummary;
        _energyStatistics = statistics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _connectSocket() async {
    final token = await ServiceLocator.instance.authService.getStoredToken();
    if (token == null || token.isEmpty) {
      return;
    }

    final socketService = ServiceLocator.instance.socketService;
    socketService.connect(url: AppConstants.websocketUrl, token: token);

    socketService.on('energy:live', (data) {
      if (!mounted || data is! Map) {
        return;
      }

      setState(() {
        _reading = EnergyReading.fromSocketPayload(
          Map<String, dynamic>.from(data),
        );
      });
    });

    socketService.on('inverter:live-status', (data) {
      if (!mounted || data is! Map) {
        return;
      }

      setState(() {
        _inverterStatus = Map<String, dynamic>.from(data);
      });
    });

    socketService.on('heartbeat:ping', (_) {
      socketService.handleHeartbeatPing();
    });

    socketService.subscribeToEnergy();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headingSmall.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
            )
          : CustomScrollView(
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
                            Text(
                              'Good Morning ☀️',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              'SolarConnect',
                              style: AppTextStyles.headingMedium.copyWith(
                                color: AppColors.primary,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.success.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.wb_sunny_rounded,
                                color: AppColors.warning,
                                size: 14,
                              ),
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
                  padding: const EdgeInsets.only(
                    bottom: AppConstants.paddingXL,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      EnergyFlowSection(reading: _reading),
                      const SizedBox(height: AppConstants.paddingMD),
                      EnergyStatsSection(reading: _reading),
                      const SizedBox(height: AppConstants.paddingMD),
                      BatteryCard(reading: _reading),
                      const SizedBox(height: AppConstants.paddingMD),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.paddingMD,
                        ),
                        child: EconomicBenefitsCard(
                          solarTodayKwh: _reading.solarTodayKwh,
                          solarTotalKwh: _reading.solarTodayKwh * 287,
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingMD),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.paddingMD,
                        ),
                        child: EnvironmentalBenefitsCard(
                          data: EnvironmentalData.fromGeneration(
                            _reading.solarTodayKwh,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingMD),
                      _AccumulatedCard(reading: _reading),
                      const SizedBox(height: AppConstants.paddingMD),
                      if (_energyStatistics != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.paddingMD,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Energy Statistics',
                                style: AppTextStyles.headingSmall,
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  _StatChip(
                                    label: 'Total Gen',
                                    value:
                                        '${(_energyStatistics!['totalGenerated'] ?? 0).toString()}',
                                  ),
                                  _StatChip(
                                    label: 'Total Consumed',
                                    value:
                                        '${(_energyStatistics!['totalConsumed'] ?? 0).toString()}',
                                  ),
                                  _StatChip(
                                    label: 'Battery Avg',
                                    value:
                                        '${(_energyStatistics!['averageBatteryLevel'] ?? 0).toString()}%',
                                  ),
                                  _StatChip(
                                    label: 'Temp Avg',
                                    value:
                                        '${(_energyStatistics!['averageTemperature'] ?? 0).toString()}°C',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                    ]),
                  ),
                ),
              ],
            ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;

  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
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
              _stat(
                Icons.bolt_rounded,
                '$totalKwh',
                'kWh',
                'Total Generated',
                AppColors.warning,
              ),
              _divider(),
              _stat(
                Icons.eco_rounded,
                '$co2Saved',
                'kg',
                'CO₂ Saved',
                AppColors.success,
              ),
              _divider(),
              _stat(
                Icons.savings_rounded,
                '\$$moneySaved',
                '',
                'Savings',
                AppColors.primary,
              ),
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

  Widget _stat(
    IconData icon,
    String value,
    String unit,
    String label,
    Color color,
  ) => Expanded(
    child: Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: AppTextStyles.headingSmall.copyWith(
                  color: color,
                  fontSize: 15,
                ),
              ),
              if (unit.isNotEmpty)
                TextSpan(text: ' $unit', style: AppTextStyles.labelSmall),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.labelSmall,
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}
