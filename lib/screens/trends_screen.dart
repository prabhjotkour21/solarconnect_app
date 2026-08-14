import 'package:flutter/material.dart';
import '../models/trend_data.dart';
import '../services/service_locator.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum _Filter { today, weekly, monthly, yearly, custom }

class TrendsScreen extends StatefulWidget {
  const TrendsScreen({super.key});

  @override
  State<TrendsScreen> createState() => _TrendsScreenState();
}

class _TrendsScreenState extends State<TrendsScreen> {
  List<TrendDataPoint> _data = [];
  _Filter _filter = _Filter.weekly; // default = weekly (shows historical data)
  DateTimeRange? _customRange;
  bool _isLoading = true;
  String? _errorMessage;
  double _totalGeneration = 0.0;

  @override
  void initState() {
    super.initState();
    _loadTrendData();
  }

  List<TrendDataPoint> get _dataPoints => _data;

  String get _filterLabel {
    switch (_filter) {
      case _Filter.today:   return 'Today';
      case _Filter.weekly:  return 'Last 7 Days';
      case _Filter.monthly: return 'Last 30 Days';
      case _Filter.yearly:  return 'Last Year';
      case _Filter.custom:
        if (_customRange != null) {
          return '${_customRange!.start.day}/${_customRange!.start.month}'
              ' – ${_customRange!.end.day}/${_customRange!.end.month}';
        }
        return 'Custom';
    }
  }

  String get _xAxisLabel {
    switch (_filter) {
      case _Filter.today:
        return 'Time of Day';
      case _Filter.weekly:
        return 'Day of Week';
      case _Filter.monthly:
        return 'Month';
      case _Filter.yearly:
        return 'Year';
      case _Filter.custom:
        return 'Date';
    }
  }

  Future<void> _loadTrendData() async {
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
      final queryParams = _buildTrendQueryParams();
      final response = await ServiceLocator.instance.energyService.getTrends(
        token,
        queryParams: queryParams,
      );

      final rawData = response['data'] as List<dynamic>? ?? [];
      final points = rawData.map((item) {
        final label = item['label']?.toString() ?? '';
        return TrendDataPoint(
          time: DateTime.tryParse(label) ?? DateTime.now(),
          value: _toDouble(item['generated'] ?? item['value']),
          label: label,
          sunlightHours: _toDouble(item['sunlightHours']),
        );
      }).toList();

      setState(() {
        _data = points;
        _totalGeneration = _toDouble(response['summary']?['totalGenerated']);
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> _buildTrendQueryParams() {
    final now = DateTime.now().toUtc();
    late final DateTime startDate;

    switch (_filter) {
      case _Filter.today:
        startDate = DateTime(now.year, now.month, now.day).toUtc();
        break;
      case _Filter.weekly:
        startDate = now.subtract(const Duration(days: 6));
        break;
      case _Filter.monthly:
        startDate = now.subtract(const Duration(days: 30));
        break;
      case _Filter.yearly:
        startDate = now.subtract(const Duration(days: 365));
        break;
      case _Filter.custom:
        if (_customRange != null) {
          return {
            'granularity': 'daily',
            'startDate': _customRange!.start.toUtc().toIso8601String(),
            'endDate': _customRange!.end.toUtc().add(const Duration(days: 1)).toIso8601String(),
          };
        }
        startDate = DateTime(now.year, now.month, now.day).toUtc();
        break;
    }

    return {
      'startDate': startDate.toIso8601String(),
      'endDate': now.toIso8601String(),
      'granularity': _filter == _Filter.today
          ? 'hourly'
          : _filter == _Filter.weekly
              ? 'daily'
              : _filter == _Filter.monthly
                  ? 'monthly'
                  : 'yearly',
    };
  }

  double _toDouble(Object? value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  // ── Filter bottom sheet ────────────────────────────────────────────────────
  void _showFilterSheet() {
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
            const SizedBox(height: 4),
            Text('Applies to both Solar & Sunlight graphs',
                style: AppTextStyles.labelSmall
                    .copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            _filterOption(Icons.today_rounded,          'Today',        _Filter.today),
            _filterOption(Icons.view_week_rounded,      'Weekly',       _Filter.weekly),
            _filterOption(Icons.calendar_month_rounded, 'Monthly',      _Filter.monthly),
            _filterOption(Icons.calendar_today_rounded, 'Yearly',       _Filter.yearly),
            _filterOption(Icons.date_range_rounded,     'Custom Range', _Filter.custom),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _filterOption(IconData icon, String label, _Filter value) {
    final selected = _filter == value;
    return GestureDetector(
      onTap: () async {
        Navigator.pop(context);
        if (value == _Filter.custom) {
          await _pickCustomRange();
        } else {
          setState(() {
            _filter = value;
            _customRange = null;
          });
          await _loadTrendData();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? AppColors.primary : Colors.white54, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.primary : Colors.white70,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 15,
              ),
            ),
            const Spacer(),
            if (selected)
              Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _pickCustomRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _customRange,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.dark(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _customRange = picked;
        _filter = _Filter.custom;
      });
      await _loadTrendData();
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final data = _dataPoints;
    final hasData = data.isNotEmpty;
    final maxVal = hasData
        ? data.map((e) => e.value).reduce((a, b) => a > b ? a : b) * 1.2
        : 1.0;
    final rangeLabel = hasData ? '${data.first.label} – ${data.last.label}' : 'No data';

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
        actions: [
          // Reset to Weekly
          IconButton(
            tooltip: 'Reset to Weekly',
            icon: Icon(Icons.restore_rounded, color: AppColors.primary),
            onPressed: () async {
              setState(() {
                _filter = _Filter.weekly;
                _customRange = null;
              });
              await _loadTrendData();
            },
          ),
          // Filter icon
          GestureDetector(
            onTap: _showFilterSheet,
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.tune_rounded, color: AppColors.primary, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    _filterLabel,
                    style: TextStyle(
                      color: AppColors.primary,
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
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headingSmall.copyWith(color: AppColors.error),
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!hasData)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'No trend data available for the selected range.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              )
            else ...[
              // ── Solar Generation chart ───────────────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(8, 14, 12, 10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.bolt_rounded,
                            color: AppColors.primary, size: 18),
                        const SizedBox(width: 6),
                        Text('Solar Generation',
                            style: AppTextStyles.headingSmall),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      rangeLabel,
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    _buildBarChart(
                      data: data,
                      getValue: (p) => p.value,
                      yMax: maxVal,
                      yAxisLabel: 'Power (kW)',
                      xAxisLabel: _xAxisLabel,
                      valueFormat: (v) => v.toStringAsFixed(1),
                      barColor: AppColors.primary,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _StatTile(
                            label: 'Total',
                            value: '${_totalGeneration.toStringAsFixed(2)} kWh',
                            icon: Icons.bolt_rounded,
                            color: AppColors.primary,
                          ),
                          _StatTile(
                            label: 'Max',
                            value:
                                '${data.map((e) => e.value).reduce((a, b) => a > b ? a : b).toStringAsFixed(2)} kW',
                            icon: Icons.trending_up_rounded,
                            color: AppColors.warning,
                          ),
                          _StatTile(
                            label: 'Avg',
                            value:
                                '${(data.map((e) => e.value).reduce((a, b) => a + b) / data.length).toStringAsFixed(2)} kW',
                            icon: Icons.equalizer_rounded,
                            color: AppColors.success,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Sunlight Hours chart ─────────────────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(8, 14, 12, 10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.wb_sunny_rounded,
                            color: AppColors.warning, size: 18),
                        const SizedBox(width: 6),
                        Text('Sunlight Hours',
                            style: AppTextStyles.headingSmall),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      rangeLabel,
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    _buildSunlightChart(data),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _StatTile(
                            label: 'Avg / Period',
                            value:
                                '${(data.map((p) => p.sunlightHours).reduce((a, b) => a + b) / data.length).toStringAsFixed(1)} hrs',
                            icon: Icons.wb_sunny_rounded,
                            color: AppColors.warning,
                          ),
                          _StatTile(
                            label: 'Peak',
                            value:
                                '${data.map((p) => p.sunlightHours).reduce((a, b) => a > b ? a : b).toStringAsFixed(1)} hrs',
                            icon: Icons.light_mode_rounded,
                            color: const Color(0xFFFF6D00),
                          ),
                          _StatTile(
                            label: 'Total',
                            value:
                                '${data.map((p) => p.sunlightHours).reduce((a, b) => a + b).toStringAsFixed(1)} hrs',
                            icon: Icons.calendar_today_rounded,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Detailed table ───────────────────────────────────────────────
              Text('Detailed Data', style: AppTextStyles.headingMedium),
              const SizedBox(height: 12),
              ...data.map((point) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 48,
                          child: Text(point.label,
                              style: AppTextStyles.labelSmall
                                  .copyWith(color: AppColors.textPrimary)),
                        ),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: maxVal > 0 ? point.value / maxVal : 0,
                              minHeight: 6,
                              backgroundColor:
                                  AppColors.primary.withValues(alpha: 0.1),
                              valueColor:
                                  AlwaysStoppedAnimation(AppColors.success),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 60,
                          child: Text(
                            '${point.value.toStringAsFixed(2)} kW',
                            style: AppTextStyles.labelSmall
                                .copyWith(color: AppColors.textSecondary),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  // ── Generic bar chart ──────────────────────────────────────────────────────
  Widget _buildBarChart({
    required List<TrendDataPoint> data,
    required double Function(TrendDataPoint) getValue,
    required double yMax,
    required String yAxisLabel,
    required String xAxisLabel,
    required String Function(double) valueFormat,
    required Color barColor,
  }) {
    const chartH  = 150.0;
    const barW    = 28.0;
    const itemW   = 46.0;
    const yLabelW = 42.0;
    final ySteps  = List.generate(5, (i) => yMax * (1 - i / 4));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            SizedBox(
              height: chartH,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  RotatedBox(
                    quarterTurns: 3,
                    child: Text(yAxisLabel,
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 9)),
                  ),
                  const SizedBox(width: 2),
                  SizedBox(
                    width: yLabelW,
                    height: chartH,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: ySteps
                          .map((v) => Text(v.toStringAsFixed(1),
                              style: const TextStyle(
                                  color: Colors.white38, fontSize: 9)))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
          ],
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: chartH,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: data.length * itemW,
                    child: Stack(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(
                              5,
                              (_) => Divider(
                                  height: 1,
                                  color: Colors.white.withValues(alpha: 0.07))),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: data.map((p) {
                            final val  = getValue(p);
                            final barH = yMax > 0
                                ? ((val / yMax) * (chartH - 8))
                                    .clamp(4.0, chartH - 8)
                                : 4.0;
                            return SizedBox(
                              width: itemW,
                              height: chartH,
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(valueFormat(val),
                                        style: const TextStyle(
                                            color: Colors.white54,
                                            fontSize: 8)),
                                    const SizedBox(height: 2),
                                    Container(
                                      width: barW,
                                      height: barH,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            barColor,
                                            barColor.withValues(alpha: 0.5),
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                        borderRadius:
                                            const BorderRadius.vertical(
                                                top: Radius.circular(6)),
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
              SizedBox(
                height: 14,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: data
                        .map((p) => SizedBox(
                              width: itemW,
                              child: Text(p.label,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      color: Colors.white38, fontSize: 9)),
                            ))
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(xAxisLabel,
                  style:
                      const TextStyle(color: Colors.white38, fontSize: 9)),
            ],
          ),
        ),
      ],
    );
  }

  // ── Sunlight chart (warm gradient bars) ────────────────────────────────────
  Widget _buildSunlightChart(List<TrendDataPoint> data) {
    final maxSun = data.isNotEmpty
        ? data.map((p) => p.sunlightHours).reduce((a, b) => a > b ? a : b)
        : 0.0;
    final yMax = (maxSun * 1.2).clamp(1.0, 14.0);

    return _buildBarChart(
      data: data,
      getValue: (p) => p.sunlightHours,
      yMax: yMax,
      yAxisLabel: 'Sunlight (hrs)',
      xAxisLabel: _xAxisLabel,
      valueFormat: (v) => '${v.toStringAsFixed(1)}h',
      // warm colour — overridden per bar via gradient in the generic builder
      barColor: AppColors.warning,
    );
  }
}

// ── Reusable stat tile ─────────────────────────────────────────────────────
class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(label,
            style: AppTextStyles.labelSmall
                .copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text(value,
            style: AppTextStyles.labelSmall
                .copyWith(color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
