import 'package:flutter/material.dart';
import '../models/trend_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum _SunFilter { today, weekly, monthly, yearly, custom }

class TrendsScreen extends StatefulWidget {
  const TrendsScreen({super.key});

  @override
  State<TrendsScreen> createState() => _TrendsScreenState();
}

class _TrendsScreenState extends State<TrendsScreen> {
  late TrendData _trends;
  String _selectedPeriod = 'hourly';
  _SunFilter _sunFilter = _SunFilter.weekly;
  DateTimeRange? _customRange;

  @override
  void initState() {
    super.initState();
    _trends = TrendData.demo();
  }

  // ── Solar generation data ──────────────────────────────────────────────────
  List<TrendDataPoint> get _solarData {
    switch (_selectedPeriod) {
      case 'daily':   return _trends.dailyData;
      case 'monthly': return _trends.monthlyData;
      case 'yearly':  return _trends.yearlyData;
      default:        return _trends.hourlyData;
    }
  }

  // ── Sunlight data per filter ───────────────────────────────────────────────
  List<TrendDataPoint> get _sunData {
    switch (_sunFilter) {
      case _SunFilter.today:   return _trends.hourlyData;
      case _SunFilter.weekly:  return _trends.dailyData;
      case _SunFilter.monthly: return _trends.monthlyData;
      case _SunFilter.yearly:  return _trends.yearlyData;
      case _SunFilter.custom:  return _trends.dailyData; // fallback
    }
  }

  String get _sunFilterLabel {
    switch (_sunFilter) {
      case _SunFilter.today:   return 'Today';
      case _SunFilter.weekly:  return 'Weekly';
      case _SunFilter.monthly: return 'Monthly';
      case _SunFilter.yearly:  return 'Yearly';
      case _SunFilter.custom:
        if (_customRange != null) {
          return '${_customRange!.start.day}/${_customRange!.start.month}'
              ' – ${_customRange!.end.day}/${_customRange!.end.month}';
        }
        return 'Custom';
    }
  }

  String get _sunXAxisLabel {
    switch (_sunFilter) {
      case _SunFilter.today:   return 'Time of Day';
      case _SunFilter.weekly:  return 'Day of Week';
      case _SunFilter.monthly: return 'Month';
      case _SunFilter.yearly:  return 'Year';
      case _SunFilter.custom:  return 'Date';
    }
  }

  double get _solarMaxValue {
    final data = _solarData;
    return data.map((e) => e.value).reduce((a, b) => a > b ? a : b) * 1.2;
  }

  // ── Filter bottom sheet ────────────────────────────────────────────────────
  void _showSunFilterSheet() {
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
            Text('Sunlight Period', style: AppTextStyles.headingMedium),
            const SizedBox(height: 16),
            _filterOption(Icons.today_rounded,          'Today',   _SunFilter.today),
            _filterOption(Icons.view_week_rounded,      'Weekly',  _SunFilter.weekly),
            _filterOption(Icons.calendar_month_rounded, 'Monthly', _SunFilter.monthly),
            _filterOption(Icons.calendar_today_rounded, 'Yearly',  _SunFilter.yearly),
            _filterOption(Icons.date_range_rounded,     'Custom Range', _SunFilter.custom),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _filterOption(IconData icon, String label, _SunFilter value) {
    final selected = _sunFilter == value;
    return GestureDetector(
      onTap: () async {
        Navigator.pop(context);
        if (value == _SunFilter.custom) {
          await _pickCustomRange();
        } else {
          setState(() => _sunFilter = value);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.warning.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.warning : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? AppColors.warning : Colors.white54, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.warning : Colors.white70,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 15,
              ),
            ),
            const Spacer(),
            if (selected)
              Icon(Icons.check_circle_rounded, color: AppColors.warning, size: 20),
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
          colorScheme: ColorScheme.dark(primary: AppColors.warning),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _customRange = picked;
        _sunFilter = _SunFilter.custom;
      });
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final solarData = _solarData;
    final maxVal    = _solarMaxValue;

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

            // ── Period selector (solar generation) ──────────────────────────
            Row(
              children: ['Hourly', 'Daily', 'Monthly', 'Yearly']
                  .asMap()
                  .entries
                  .map((e) {
                final isSelected = _selectedPeriod == e.value.toLowerCase();
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(
                        () => _selectedPeriod = e.value.toLowerCase()),
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
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
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

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
                  Text('Solar Generation',
                      style: AppTextStyles.headingSmall),
                  const SizedBox(height: 4),
                  Text(
                    '${solarData.first.label} – ${solarData.last.label}',
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  _buildSolarChart(solarData, maxVal),
                  const SizedBox(height: 16),
                  // Stats row
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
                          value: '${_trends.totalGeneration} kWh',
                          icon: Icons.bolt_rounded,
                          color: AppColors.primary,
                        ),
                        _StatTile(
                          label: 'Max',
                          value:
                              '${solarData.map((e) => e.value).reduce((a, b) => a > b ? a : b).toStringAsFixed(2)} kW',
                          icon: Icons.trending_up_rounded,
                          color: AppColors.warning,
                        ),
                        _StatTile(
                          label: 'Avg',
                          value:
                              '${(solarData.map((e) => e.value).reduce((a, b) => a + b) / solarData.length).toStringAsFixed(2)} kW',
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.wb_sunny_rounded,
                        color: AppColors.warning, size: 20),
                    const SizedBox(width: 8),
                    Text('Sunlight Hours',
                        style: AppTextStyles.headingMedium),
                  ],
                ),
                // Filter icon button
                GestureDetector(
                  onTap: _showSunFilterSheet,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.tune_rounded,
                            color: AppColors.warning, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          _sunFilterLabel,
                          style: TextStyle(
                            color: AppColors.warning,
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
              padding: const EdgeInsets.fromLTRB(8, 14, 12, 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(16),
              ),
              child: _buildSunlightChart(_sunData),
            ),
            const SizedBox(height: 24),

            // ── Detailed table ───────────────────────────────────────────────
            Text('Detailed Data', style: AppTextStyles.headingMedium),
            const SizedBox(height: 12),
            ...solarData.map((point) => Container(
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
                            valueColor: AlwaysStoppedAnimation(AppColors.success),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 56,
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
        ),
      ),
    );
  }

  // ── Solar bar chart ────────────────────────────────────────────────────────
  Widget _buildSolarChart(List<TrendDataPoint> data, double maxVal) {
    const chartH  = 150.0;
    const barW    = 28.0;
    const itemW   = 46.0;
    const yLabelW = 42.0;

    final ySteps = List.generate(5, (i) => maxVal * (1 - i / 4));

    return Row(
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
                    child: const Text('Power (kW)',
                        style: TextStyle(color: Colors.white38, fontSize: 9)),
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
        // Chart
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
                                  color: Colors.white
                                      .withValues(alpha: 0.07))),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: data.map((p) {
                            final barH = maxVal > 0
                                ? ((p.value / maxVal) * (chartH - 8))
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
                                    Text(
                                      p.value.toStringAsFixed(1),
                                      style: const TextStyle(
                                          color: Colors.white54,
                                          fontSize: 8),
                                    ),
                                    const SizedBox(height: 2),
                                    Container(
                                      width: barW,
                                      height: barH,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppColors.primary,
                                            AppColors.primary
                                                .withValues(alpha: 0.5),
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
              // X-axis labels
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
              Text(
                _selectedPeriod == 'hourly' ? 'Time of Day' : 'Period',
                style: const TextStyle(color: Colors.white38, fontSize: 9),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Sunlight hours bar chart ───────────────────────────────────────────────
  Widget _buildSunlightChart(List<TrendDataPoint> data) {
    const chartH  = 160.0;
    const barW    = 28.0;
    const itemW   = 46.0;
    const yLabelW = 38.0;
    const yMaxH   = 12.0; // max sunlight hours on Y scale

    // Y steps: 0 → 12 hours
    final ySteps = List.generate(5, (i) => yMaxH * (1 - i / 4));

    final maxSun = data
        .map((p) => p.sunlightHours)
        .reduce((a, b) => a > b ? a : b);
    final yMax = (maxSun * 1.2).clamp(1.0, 14.0);

    // Summary stats
    final avgSun = data.map((p) => p.sunlightHours).reduce((a, b) => a + b) /
        data.length;
    final maxSunVal =
        data.map((p) => p.sunlightHours).reduce((a, b) => a > b ? a : b);

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
                        child: const Text('Sunlight (hrs)',
                            style: TextStyle(
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
                              .map((v) => Text('${v.toStringAsFixed(0)}h',
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
                        width: data.length * itemW,
                        child: Stack(
                          children: [
                            // Grid lines
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(
                                  5,
                                  (_) => Divider(
                                      height: 1,
                                      color: Colors.white
                                          .withValues(alpha: 0.07))),
                            ),
                            // Bars — warm gradient (orange→yellow for summer peaks)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: data.map((p) {
                                final barH = yMax > 0
                                    ? ((p.sunlightHours / yMax) *
                                            (chartH - 8))
                                        .clamp(4.0, chartH - 8)
                                    : 4.0;
                                // Warmer colour for more sun (summer)
                                final intensity =
                                    (p.sunlightHours / yMax).clamp(0.0, 1.0);
                                final barColor = Color.lerp(
                                    const Color(0xFFFFB300),
                                    const Color(0xFFFF6D00),
                                    intensity)!;
                                return SizedBox(
                                  width: itemW,
                                  height: chartH,
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '${p.sunlightHours.toStringAsFixed(1)}h',
                                          style: const TextStyle(
                                              color: Colors.white54,
                                              fontSize: 8),
                                        ),
                                        const SizedBox(height: 2),
                                        Container(
                                          width: barW,
                                          height: barH,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                barColor,
                                                barColor.withValues(
                                                    alpha: 0.5),
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
                  // X-axis labels
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
                                          color: Colors.white38,
                                          fontSize: 9)),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _sunXAxisLabel,
                    style:
                        const TextStyle(color: Colors.white38, fontSize: 9),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        // Sunlight summary stats
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
                label: 'Avg / Day',
                value: '${avgSun.toStringAsFixed(1)} hrs',
                icon: Icons.wb_sunny_rounded,
                color: AppColors.warning,
              ),
              _StatTile(
                label: 'Peak Day',
                value: '${maxSunVal.toStringAsFixed(1)} hrs',
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
            style: AppTextStyles.labelSmall.copyWith(
                color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
