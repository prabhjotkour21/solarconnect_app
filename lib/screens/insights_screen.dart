import 'package:flutter/material.dart';
import '../services/service_locator.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic> _summary = {};
  List<dynamic> _series = [];

  @override
  void initState() {
    super.initState();
    _loadInsights();
  }

  Future<void> _loadInsights() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final token = await ServiceLocator.instance.authService.getStoredToken();
    if (token == null || token.isEmpty) {
      setState(() {
        _errorMessage = 'Authentication token not found. Please login again.';
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await ServiceLocator.instance.insightsService.getInsights(
        token,
        queryParams: {'granularity': 'daily'},
      );

      final summary = response['summary'] as Map<String, dynamic>? ?? {};
      final series = response['series'] as List<dynamic>? ?? [];

      setState(() {
        _summary = summary;
        _series = series;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = 'Unable to load insights. Please try again later.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: AppBar(
          backgroundColor: AppColors.surfaceDark,
          elevation: 0,
          title: Text('Insights', style: AppTextStyles.headingLarge),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: AppTextStyles.headingSmall.copyWith(color: AppColors.error),
            ),
          ),
        ),
      );
    }

    final totalGenerated = (_summary['totalGenerated'] ?? 0).toDouble();
    final totalConsumed = (_summary['totalConsumed'] ?? 0).toDouble();
    final selfPowered = totalConsumed > 0
        ? ((totalGenerated / totalConsumed) * 100).clamp(0.0, 100.0)
        : 0.0;

    final comparisonItems = _series.isEmpty
        ? <Map<String, dynamic>>[]
        : _series.map((item) {
            final label = item['label']?.toString() ?? 'N/A';
            final generated = (item['generated'] ?? 0).toDouble();
            final consumed = (item['consumed'] ?? 0).toDouble();
            final percentage = consumed > 0
                ? ((generated / consumed) * 100).clamp(0.0, 100.0)
                : 0.0;
            return {
              'day': label,
              'percentage': percentage,
              'generation': '${generated.toStringAsFixed(1)} kWh',
            };
          }).toList();

    final peakUsage = _series.isEmpty
        ? '0.0 kW'
        : '${_series.map((item) => (item['consumed'] ?? 0).toDouble()).reduce((a, b) => a > b ? a : b).toStringAsFixed(1)} kW';

    final peakGeneration = _series.isEmpty
        ? '0.0 kW'
        : '${_series.map((item) => (item['generated'] ?? 0).toDouble()).reduce((a, b) => a > b ? a : b).toStringAsFixed(1)} kW';

    final batteryLevel = (_summary['batteryCharging']?['averageBatteryLevel'] ?? 0).toDouble();
    final gridExport = (_summary['gridUsage']?['totalGridSupply'] ?? 0).toDouble();
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
        title: Text('Insights', style: AppTextStyles.headingLarge),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.trending_up_rounded,
                    size: 48,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${selfPowered.toStringAsFixed(1)}%',
                    style: AppTextStyles.headingLarge.copyWith(
                      color: AppColors.primary,
                      fontSize: 42,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Self Powered',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'of the total amount of electricity used in your period, ${selfPowered.toStringAsFixed(1)}% was supplied by your solar system',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Weekly Comparison',
              style: AppTextStyles.headingMedium,
            ),
            const SizedBox(height: 12),
            if (comparisonItems.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'No insight data available for the selected period.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              )
            else
              ...comparisonItems.map((item) {
                final percentage = (item['percentage'] as double).clamp(0.0, 100.0);
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['day'] as String,
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['generation'] as String,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${percentage.toStringAsFixed(0)}%',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: percentage / 100,
                                minHeight: 6,
                                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                valueColor: AlwaysStoppedAnimation(
                                  percentage >= 60 ? AppColors.success : AppColors.warning,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            const SizedBox(height: 24),
            Text(
              'Key Metrics',
              style: AppTextStyles.headingMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    label: 'Peak Usage',
                    value: peakUsage,
                    time: 'Selected period',
                    icon: Icons.flash_on_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    label: 'Peak Generation',
                    value: peakGeneration,
                    time: 'Selected period',
                    icon: Icons.wb_sunny_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    label: 'Battery Cycles',
                    value: batteryLevel.toStringAsFixed(1),
                    time: 'Avg battery %',
                    icon: Icons.battery_std_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    label: 'Grid Export',
                    value: '${gridExport.toStringAsFixed(1)} kWh',
                    time: 'Selected period',
                    icon: Icons.cloud_upload_rounded,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String time;
  final IconData icon;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.time,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
