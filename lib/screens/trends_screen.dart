import 'package:flutter/material.dart';
import '../../models/trend_data.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class TrendsScreen extends StatefulWidget {
  const TrendsScreen({super.key});

  @override
  State<TrendsScreen> createState() => _TrendsScreenState();
}

class _TrendsScreenState extends State<TrendsScreen> {
  late TrendData _trends;
  String _selectedPeriod = 'hourly'; // hourly, daily, monthly

  @override
  void initState() {
    super.initState();
    _trends = TrendData.demo();
  }

  List<TrendDataPoint> _getDataForPeriod() {
    switch (_selectedPeriod) {
      case 'daily':
        return _trends.dailyData;
      case 'monthly':
        return _trends.monthlyData;
      default:
        return _trends.hourlyData;
    }
  }

  double _getMaxValue() {
    final data = _getDataForPeriod();
    return data.map((e) => e.value).reduce((a, b) => a > b ? a : b) * 1.2;
  }

  @override
  Widget build(BuildContext context) {
    final data = _getDataForPeriod();
    final maxValue = _getMaxValue();

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
        title: Text('Trends', style: AppTextStyles.headingLarge),
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
            // Period selector
            Row(
              children: ['Hourly', 'Daily', 'Monthly'].asMap().entries.map((e) {
                final isSelected =
                    _selectedPeriod == e.value.toLowerCase();
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPeriod = e.value.toLowerCase();
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          e.value,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isSelected
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Chart container
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today's solar generation - ${data.first.label} to ${data.last.label}",
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Simple bar chart
                  SizedBox(
                    height: 200,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: data.map((point) {
                        final height = (point.value / maxValue) * 150;
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              width: 30,
                              height: height,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(8),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: 40,
                              child: Text(
                                point.label,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 10,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  
                  const SizedBox(height: 20),

                  // Stats
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatCard(
                          label: 'Total',
                          value: '${_trends.totalGeneration} kWh',
                          icon: Icons.bolt_rounded,
                        ),
                        _StatCard(
                          label: 'Max',
                          value: '${data.map((e) => e.value).reduce((a, b) => a > b ? a : b).toStringAsFixed(2)} kW',
                          icon: Icons.trending_up_rounded,
                        ),
                        _StatCard(
                          label: 'Avg',
                          value: '${(data.map((e) => e.value).reduce((a, b) => a + b) / data.length).toStringAsFixed(2)} kW',
                          icon: Icons.equalizer_rounded,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Data table
            Text(
              'Detailed Data',
              style: AppTextStyles.headingMedium,
            ),
            const SizedBox(height: 12),
            ...data.map((point) {
              final percentage = (point.value / maxValue) * 100;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        point.label,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: point.value / maxValue,
                          minHeight: 6,
                          backgroundColor:
                              AppColors.primary.withValues(alpha: 0.1),
                          valueColor: AlwaysStoppedAnimation(
                            AppColors.success,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 50,
                      child: Text(
                        '${point.value.toStringAsFixed(2)} kW',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
