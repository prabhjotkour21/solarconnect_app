import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/savings_data.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

enum _Period { today, yesterday, weekly, monthly, custom }

// Savings data per period
const _periodData = {
  _Period.today: {
    'totalSavings': 48.0,
    'dailyAverage': 48.0,
    'lastPeriodSavings': 48.0,
    'label': "Today's Savings",
    'breakdownLabel': 'Today',
    'bars': [
      {'label': '8AM', 'value': 10},
      {'label': '12PM', 'value': 18},
      {'label': '4PM', 'value': 20},
    ],
  },
  _Period.yesterday: {
    'totalSavings': 52.0,
    'dailyAverage': 52.0,
    'lastPeriodSavings': 52.0,
    'label': "Yesterday's Savings",
    'breakdownLabel': 'Yesterday',
    'bars': [
      {'label': '8AM', 'value': 12},
      {'label': '12PM', 'value': 22},
      {'label': '4PM', 'value': 18},
    ],
  },
  _Period.weekly: {
    'totalSavings': 320.0,
    'dailyAverage': 45.7,
    'lastPeriodSavings': 320.0,
    'label': 'This Week\'s Savings',
    'breakdownLabel': 'This Week',
    'bars': [
      {'label': 'Mon', 'value': 44},
      {'label': 'Wed', 'value': 50},
      {'label': 'Fri', 'value': 48},
    ],
  },
  _Period.monthly: {
    'totalSavings': 1450.0,
    'dailyAverage': 48.3,
    'lastPeriodSavings': 1450.0,
    'label': 'This Month\'s Savings',
    'breakdownLabel': 'This Month',
    'bars': [
      {'label': 'Jun', 'value': 89},
      {'label': 'Jul', 'value': 120},
      {'label': 'Aug', 'value': 145},
    ],
  },
  _Period.custom: {
    'totalSavings': 0.0,
    'dailyAverage': 0.0,
    'lastPeriodSavings': 0.0,
    'label': 'Custom Period',
    'breakdownLabel': 'Custom',
    'bars': [
      {'label': 'Day 1', 'value': 0},
      {'label': 'Day 2', 'value': 0},
      {'label': 'Day 3', 'value': 0},
    ],
  },
};

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  double _investmentAmount = 1740;
  _Period _selectedPeriod = _Period.today;
  DateTimeRange? _customRange;

  Map<String, dynamic> get _data => _periodData[_selectedPeriod]!;

  void _showInvestmentDialog() {
    final controller = TextEditingController(
      text: _investmentAmount.toStringAsFixed(0),
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: Text('Enter Investment', style: AppTextStyles.headingMedium),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: AppTextStyles.labelLarge,
          decoration: InputDecoration(
            prefixText: '₹ ',
            prefixStyle: AppTextStyles.labelLarge.copyWith(
              color: AppColors.success,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.success.withValues(alpha: 0.4),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.success),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              final val = double.tryParse(controller.text);
              if (val != null && val > 0) {
                setState(() => _investmentAmount = val);
              }
              Navigator.pop(ctx);
            },
            child: Text(
              'Save',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickCustomRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _customRange,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.dark(
            primary: AppColors.success,
            surface: AppColors.surfaceDark,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (range != null) {
      final days = range.end.difference(range.start).inDays + 1;
      final total = days * 48.0;
      setState(() {
        _customRange = range;
        _periodData[_Period.custom]!['totalSavings'] = total;
        _periodData[_Period.custom]!['dailyAverage'] = 48.0;
        _periodData[_Period.custom]!['lastPeriodSavings'] = total;
        _periodData[_Period.custom]!['label'] =
            '${range.start.day}/${range.start.month} – ${range.end.day}/${range.end.month}';
        _periodData[_Period.custom]!['bars'] = [
          {'label': 'Start', 'value': 44},
          {'label': 'Mid', 'value': (days * 48 / 3).round()},
          {'label': 'End', 'value': 50},
        ];
      });
    }
  }

  void _onPeriodTap(_Period period) {
    if (period == _Period.custom) {
      _pickCustomRange();
    }
    setState(() => _selectedPeriod = period);
  }

  @override
  Widget build(BuildContext context) {
    final totalSavings = _data['totalSavings'] as double;
    final dailyAverage = _data['dailyAverage'] as double;
    final lastPeriodSavings = _data['lastPeriodSavings'] as double;
    final periodLabel = _data['label'] as String;
    final breakdownLabel = _data['breakdownLabel'] as String;
    final bars = _data['bars'] as List;

    final savings = SavingsData(
      totalSavings: totalSavings,
      dailyAverage: dailyAverage,
      lastMonthSavings: lastPeriodSavings,
      roi: _investmentAmount > 0 ? (totalSavings / _investmentAmount) * 100 : 0,
      investmentAmount: _investmentAmount,
      roi_months: _investmentAmount > 0 ? (_investmentAmount / 48).ceil() : 0,
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
        title: Text('Savings', style: AppTextStyles.headingLarge),
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
            // Main savings card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.success.withValues(alpha: 0.2),
                    AppColors.primary.withValues(alpha: 0.2),
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.savings_rounded,
                    size: 48,
                    color: AppColors.success,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '₹${savings.totalSavings.toStringAsFixed(0)}',
                    style: AppTextStyles.headingLarge.copyWith(
                      color: AppColors.success,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    periodLabel,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Filter tabs
            Row(
              children: [
                ...[
                  _Period.today,
                  _Period.yesterday,
                  _Period.weekly,
                  _Period.monthly,
                ].map((period) {
                  final labels = {
                    _Period.today: 'Today',
                    _Period.yesterday: 'Yesterday',
                    _Period.weekly: 'Weekly',
                    _Period.monthly: 'Monthly',
                  };
                  final isSelected = _selectedPeriod == period;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => _onPeriodTap(period),
                      child: Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.success.withValues(alpha: 0.2)
                              : AppColors.surfaceDark,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.success.withValues(alpha: 0.5)
                                : AppColors.surfaceDark,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            labels[period]!,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: isSelected
                                  ? AppColors.success
                                  : AppColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                GestureDetector(
                  onTap: () => _onPeriodTap(_Period.custom),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      color: _selectedPeriod == _Period.custom
                          ? AppColors.success.withValues(alpha: 0.2)
                          : AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _selectedPeriod == _Period.custom
                            ? AppColors.success.withValues(alpha: 0.5)
                            : AppColors.surfaceDark,
                      ),
                    ),
                    child: Icon(
                      Icons.menu_rounded,
                      size: 16,
                      color: _selectedPeriod == _Period.custom
                          ? AppColors.success
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Savings breakdown
            Text('Savings Breakdown', style: AppTextStyles.headingMedium),
            const SizedBox(height: 12),

            _SavingsCard(
              label: breakdownLabel,
              value: '₹${savings.dailyAverage.toStringAsFixed(0)}',
              icon: Icons.calendar_today_rounded,
              color: AppColors.primary,
            ),
            const SizedBox(height: 12),

            _SavingsCard(
              label: 'Total Period',
              value: '₹${savings.lastMonthSavings.toStringAsFixed(0)}',
              icon: Icons.date_range_rounded,
              color: AppColors.success,
            ),
            const SizedBox(height: 24),

            // ROI and Investment
            Text('Investment Details', style: AppTextStyles.headingMedium),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.trending_up_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'ROI',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${savings.roi.toStringAsFixed(2)}%',
                          style: AppTextStyles.headingMedium.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(
                              Icons.attach_money_rounded,
                              color: AppColors.success,
                              size: 24,
                            ),
                            GestureDetector(
                              onTap: _showInvestmentDialog,
                              child: Icon(
                                Icons.edit_rounded,
                                color: AppColors.textSecondary,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Investment',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: _showInvestmentDialog,
                          child: Text(
                            '₹${savings.investmentAmount.toStringAsFixed(0)}',
                            style: AppTextStyles.headingMedium.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.hourglass_bottom_rounded,
                        color: AppColors.warning,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Break Even Period',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            savings.roiMonthsDisplay,
                            style: AppTextStyles.headingMedium.copyWith(
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ), //Row in this line  in colum and romw
                  const SizedBox(height: 12),
                  Text(
                    'Your system will pay for itself in ${savings.roiMonthsDisplay}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Trend chart
            Text('Savings Trend', style: AppTextStyles.headingMedium),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SizedBox(
                height: 120,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: bars
                      .map(
                        (b) => _MonthBar(
                          label: b['label'] as String,
                          value: b['value'] as int,
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavingsCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SavingsCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
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
                  style: AppTextStyles.labelLarge.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
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

class _MonthBar extends StatelessWidget {
  final String label;
  final int value;

  const _MonthBar({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 35,
          height: value > 0 ? (value / 150) * 80 : 4,
          decoration: BoxDecoration(
            color: AppColors.success,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '₹$value',
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textSecondary,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
