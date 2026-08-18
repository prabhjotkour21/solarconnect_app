import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/savings_data.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

enum _Period { today, yesterday, weekly, monthly, custom }
enum _GraphFilter { today, weekly, monthly, allTime, custom }

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  double _investmentAmount = 0;
  _Period _selectedPeriod = _Period.today;
  _GraphFilter _graphFilter = _GraphFilter.weekly;
  DateTimeRange? _customRange;
  DateTimeRange? _graphCustomRange;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  Map<String, dynamic> _summaryData = {};
  List<Map<String, dynamic>> _graphBars = [];

  @override
  void initState() {
    super.initState();
    _loadSavingsData();
  }

  Future<void> _loadSavingsData() async {
    final token = await ServiceLocator.instance.authService.getStoredToken();
    if (token == null || token.isEmpty) {
      setState(() {
        _errorMessage = 'Please login again to view savings.';
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await ServiceLocator.instance.savingsService.getSummary(
        token,
        period: _mapPeriodToApi(_selectedPeriod),
      );

      final summary = (response['summary'] ?? <String, dynamic>{}) as Map<String, dynamic>;
      final investmentResponse = await ServiceLocator.instance.userProfileService.getProfile(token);
      final userInvestment = (investmentResponse['investmentAmount'] ?? investmentResponse['data']?['investmentAmount'] ?? 0)
          .toDouble();

      final graphResponse = await ServiceLocator.instance.savingsService.getTrend(token, filter: _mapGraphFilterToApi(_graphFilter));
      final series = (graphResponse['series'] as List?) ?? const [];

      setState(() {
        _summaryData = summary;
        _investmentAmount = userInvestment;
        _graphBars = series
            .map<Map<String, dynamic>>((item) => {
                  'label': item['label'] ?? '',
                  'xAxis': item['label'] != null ? 'Date' : 'Value',
                  'value': (item['savedAmount'] ?? 0).round(),
                })
            .toList();
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String _mapPeriodToApi(_Period period) {
    switch (period) {
      case _Period.today:
        return 'today';
      case _Period.yesterday:
        return 'yesterday';
      case _Period.weekly:
        return 'weekly';
      case _Period.monthly:
      case _Period.custom:
        return 'monthly';
    }
  }

  String _mapGraphFilterToApi(_GraphFilter filter) {
    switch (filter) {
      case _GraphFilter.today:
        return 'today';
      case _GraphFilter.weekly:
        return 'weekly';
      case _GraphFilter.monthly:
        return 'monthly';
      case _GraphFilter.allTime:
      case _GraphFilter.custom:
        return 'alltime';
    }
  }

  Map<String, dynamic> get _data => {
        'totalSavings': (_summaryData['totalSavings'] ?? 0).toDouble(),
        'dailyAverage': (_summaryData['totalSavings'] ?? 0).toDouble(),
        'lastPeriodSavings': (_summaryData['estimatedSavings'] ?? _summaryData['totalSavings'] ?? 0).toDouble(),
        'label': "Today's Savings",
        'breakdownLabel': 'Today',
      };

  List<Map<String, dynamic>> get _graphDataList => _graphBars.isNotEmpty ? _graphBars : const [];

  Future<void> _showInvestmentDialog() async {
    final controller = TextEditingController(
      text: _investmentAmount.toStringAsFixed(0),
    );
    final confirm = await showDialog<bool>(
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
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
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

    if (confirm != true) return;

    final val = double.tryParse(controller.text);
    if (val == null || val <= 0) {
      return;
    }

    final token = await ServiceLocator.instance.authService.getStoredToken();
    if (token == null || token.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login again to update investment.')),
        );
      }
      return;
    }

    try {
      setState(() => _isSaving = true);
      await ServiceLocator.instance.savingsService.updateInvestmentAmount(token, val);
      setState(() => _investmentAmount = val);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to update investment amount')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
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
      setState(() {
        _customRange = range;
        _selectedPeriod = _Period.custom;
      });
      await _loadSavingsData();
    }
  }

  void _showGraphFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Graph Period', style: AppTextStyles.headingMedium),
            const SizedBox(height: 16),
            _graphSheetOption(Icons.today_rounded,           'Today',      _GraphFilter.today),
            _graphSheetOption(Icons.view_week_rounded,       'Weekly',     _GraphFilter.weekly),
            _graphSheetOption(Icons.calendar_month_rounded,  'Monthly',    _GraphFilter.monthly),
            _graphSheetOption(Icons.history_rounded,         'All Time',   _GraphFilter.allTime),
            _graphSheetOption(Icons.date_range_rounded,      'Custom Range', _GraphFilter.custom),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _graphSheetOption(IconData icon, String label, _GraphFilter value) {
    final selected = _graphFilter == value;
    return GestureDetector(
      onTap: () async {
        Navigator.pop(context);
        if (value == _GraphFilter.custom) {
          await _pickGraphCustomRange();
        } else {
          setState(() => _graphFilter = value);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.success.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.success : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? AppColors.success : Colors.white54, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.success : Colors.white70,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 15,
              ),
            ),
            const Spacer(),
            if (selected)
              Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _pickGraphCustomRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _graphCustomRange,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.dark(primary: AppColors.success),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _graphCustomRange = picked;
        _graphFilter = _GraphFilter.custom;
      });
      await _loadSavingsData();
    }
  }

  Future<void> _onPeriodTap(_Period period) async {
    if (period == _Period.custom) {
      await _pickCustomRange();
    }
    setState(() => _selectedPeriod = period);
    await _loadSavingsData();
  }

  String get _periodLabel {
    switch (_selectedPeriod) {
      case _Period.today:     return 'Today';
      case _Period.yesterday: return 'Yesterday';
      case _Period.weekly:    return 'Weekly';
      case _Period.monthly:   return 'Monthly';
      case _Period.custom:
        if (_customRange != null) {
          return '${_customRange!.start.day}/${_customRange!.start.month}'
              ' – ${_customRange!.end.day}/${_customRange!.end.month}';
        }
        return 'Custom';
    }
  }

  void _showPeriodFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Select Period', style: AppTextStyles.headingMedium),
            const SizedBox(height: 16),
            _periodOption(Icons.today_rounded,          'Today',        _Period.today),
            _periodOption(Icons.history_rounded,        'Yesterday',    _Period.yesterday),
            _periodOption(Icons.view_week_rounded,      'Weekly',       _Period.weekly),
            _periodOption(Icons.calendar_month_rounded, 'Monthly',      _Period.monthly),
            _periodOption(Icons.date_range_rounded,     'Custom Range', _Period.custom),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _periodOption(IconData icon, String label, _Period value) {
    final selected = _selectedPeriod == value;
    return GestureDetector(
      onTap: () async {
        Navigator.pop(context);
        if (value == _Period.custom) {
          await _pickCustomRange();
        }
        setState(() => _selectedPeriod = value);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.success.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.success : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? AppColors.success : Colors.white54, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.success : Colors.white70,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 15,
              ),
            ),
            const Spacer(),
            if (selected)
              Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalSavings = _data['totalSavings'] as double;
    final dailyAverage = _data['dailyAverage'] as double;
    final lastPeriodSavings = _data['lastPeriodSavings'] as double;
    final periodLabel = _data['label'] as String;
    final breakdownLabel = _data['breakdownLabel'] as String;

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
        actions: [
          // Reset to Today
          IconButton(
            tooltip: 'Reset to Today',
            icon: Icon(Icons.restore_rounded, color: AppColors.success),
            onPressed: () => setState(() {
              _selectedPeriod = _Period.today;
              _customRange = null;
            }),
          ),
          // Filter icon
          GestureDetector(
            onTap: _showPeriodFilterSheet,
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.tune_rounded, color: AppColors.success, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    _periodLabel,
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyLarge.copyWith(color: AppColors.error),
                    ),
                  ),
                )
              : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main savings card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
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
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.savings_rounded,
                    size: 52,
                    color: AppColors.success,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '₹${savings.totalSavings.toStringAsFixed(0)}',
                    style: AppTextStyles.headingLarge.copyWith(
                      color: AppColors.success,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    periodLabel,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (_isSaving)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: LinearProgressIndicator(),
              ),

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
                      ), // Text adding  in this line  to incress my github comment history
                    ],
                  ), //Row in this line  in colum and romw in this line i have ot add 3 comment
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Savings Trend', style: AppTextStyles.headingMedium),
                GestureDetector(
                  onTap: _showGraphFilterSheet,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.success.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.tune_rounded, color: AppColors.success, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          _graphFilterLabel,
                          style: TextStyle(
                            color: AppColors.success,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
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
              padding: const EdgeInsets.fromLTRB(8, 12, 12, 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: _buildTrendChart(_graphDataList),
            ),
          ],
        ),
      ),
    );
  }

  String get _graphFilterLabel {
    switch (_graphFilter) {
      case _GraphFilter.today:   return 'Today';
      case _GraphFilter.weekly:  return 'Weekly';
      case _GraphFilter.monthly: return 'Monthly';
      case _GraphFilter.allTime: return 'All Time';
      case _GraphFilter.custom:
        if (_graphCustomRange != null) {
          return '${_graphCustomRange!.start.day}/${_graphCustomRange!.start.month}'
              ' – ${_graphCustomRange!.end.day}/${_graphCustomRange!.end.month}';
        }
        return 'Custom';
    }
  }

  Widget _buildTrendChart(List<Map<String, dynamic>> bars) {
    const chartH = 150.0;
    const barW   = 28.0;
    const itemW  = 46.0;
    const yLabelW = 42.0;

    if (bars.isEmpty) {
      return const SizedBox(
        height: chartH,
        child: Center(child: Text('No data', style: TextStyle(color: Colors.white38))),
      );
    }

    final maxVal = bars.map((b) => b['value'] as int).reduce((a, b) => a > b ? a : b);
    final yMax   = (maxVal * 1.2).ceilToDouble();
    final ySteps = List.generate(5, (i) => (yMax * (1 - i / 4)).round());
    final xAxisLabel = bars.first['xAxis'] as String;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Y-axis
            Column(
              children: [
                SizedBox(
                  height: chartH,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      RotatedBox(
                        quarterTurns: 3,
                        child: Text(
                          'Savings (₹)',
                          style: TextStyle(color: Colors.white38, fontSize: 9),
                        ),
                      ),
                      const SizedBox(width: 2),
                      SizedBox(
                        width: yLabelW,
                        height: chartH,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: ySteps.map((v) => Text(
                            '₹$v',
                            style: const TextStyle(color: Colors.white38, fontSize: 9),
                          )).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
            const SizedBox(width: 4),
            // Chart area
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: chartH,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: bars.length * itemW,
                        child: Stack(
                          children: [
                            // Grid lines
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(
                                5,
                                (_) => Divider(
                                  height: 1,
                                  color: Colors.white.withValues(alpha: 0.07),
                                ),
                              ),
                            ),
                            // Bars
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: bars.map((b) {
                                final val = b['value'] as int;
                                final barH = yMax > 0
                                    ? ((val / yMax) * (chartH - 8)).clamp(4.0, chartH - 8)
                                    : 4.0;
                                return SizedBox(
                                  width: itemW,
                                  height: chartH,
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '₹$val',
                                          style: const TextStyle(
                                            color: Colors.white54,
                                            fontSize: 8,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Container(
                                          width: barW,
                                          height: barH,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                AppColors.success,
                                                AppColors.success.withValues(alpha: 0.6),
                                              ],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            ),
                                            borderRadius: const BorderRadius.vertical(
                                              top: Radius.circular(6),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Divider(height: 1, color: Colors.white24),
                  const SizedBox(height: 4),
                  // X-axis labels
                  SizedBox(
                    height: 14,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: bars.map((b) => SizedBox(
                          width: itemW,
                          child: Text(
                            b['label'] as String,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white38, fontSize: 9),
                          ),
                        )).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    xAxisLabel,
                    style: const TextStyle(color: Colors.white38, fontSize: 9),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
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


