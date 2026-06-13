import 'package:flutter/material.dart';
import '../models/power_cut_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum PowerCutFilter { today, weekly, monthly, allTime, custom }

class PowerCutScreen extends StatefulWidget {
  const PowerCutScreen({super.key});

  @override
  State<PowerCutScreen> createState() => _PowerCutScreenState();
}

class _PowerCutScreenState extends State<PowerCutScreen> {
  PowerCutFilter _filter = PowerCutFilter.weekly;
  DateTimeRange? _customRange;

  final List<PowerCutEvent> _allEvents = PowerCutData.demo().events;

  List<PowerCutEvent> get _filteredEvents {
    final now = DateTime.now();
    return _allEvents.where((e) {
      switch (_filter) {
        case PowerCutFilter.today:
          return e.date.year == now.year &&
              e.date.month == now.month &&
              e.date.day == now.day;
        case PowerCutFilter.weekly:
          final weekAgo = now.subtract(const Duration(days: 7));
          return e.date.isAfter(weekAgo);
        case PowerCutFilter.monthly:
          return e.date.year == now.year && e.date.month == now.month;
        case PowerCutFilter.allTime:
          return true;
        case PowerCutFilter.custom:
          if (_customRange == null) return true;
          return !e.date.isBefore(_customRange!.start) &&
              !e.date.isAfter(_customRange!.end.add(const Duration(days: 1)));
      }
    }).toList();
  }

  int get _totalDuration =>
      _filteredEvents.fold(0, (sum, e) => sum + e.durationMinutes);

  double get _avgDuration =>
      _filteredEvents.isEmpty ? 0 : _totalDuration / _filteredEvents.length;

  String get _filterLabel {
    switch (_filter) {
      case PowerCutFilter.today: return 'Today';
      case PowerCutFilter.weekly: return 'Weekly';
      case PowerCutFilter.monthly: return 'Monthly';
      case PowerCutFilter.allTime: return 'All Time';
      case PowerCutFilter.custom:
        return _customRange != null
            ? '${_fmt(_customRange!.start)} - ${_fmt(_customRange!.end)}'
            : 'Custom';
    }
  }

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
            Text('Filter by Period', style: AppTextStyles.headingMedium),
            const SizedBox(height: 16),
            _sheetOption(Icons.today_rounded, 'Today', PowerCutFilter.today),
            _sheetOption(Icons.view_week_rounded, 'Weekly', PowerCutFilter.weekly),
            _sheetOption(Icons.calendar_month_rounded, 'Monthly', PowerCutFilter.monthly),
            _sheetOption(Icons.history_rounded, 'All Time', PowerCutFilter.allTime),
            _sheetOption(Icons.date_range_rounded, 'Custom Range', PowerCutFilter.custom),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _sheetOption(IconData icon, String label, PowerCutFilter value) {
    final selected = _filter == value;
    return GestureDetector(
      onTap: () async {
        Navigator.pop(context);
        if (value == PowerCutFilter.custom) {
          await _pickCustomRange();
        } else {
          setState(() => _filter = value);
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
            color: selected
                ? AppColors.primary
                : Colors.white.withValues(alpha: 0.1),
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
        _filter = PowerCutFilter.custom;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final events = _filteredEvents;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
        title: Text('Power Cut', style: AppTextStyles.headingLarge),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            tooltip: 'Reset to Today',
            icon: Icon(Icons.restore_rounded, color: AppColors.primary),
            onPressed: () => setState(() {
              _filter = PowerCutFilter.today;
              _customRange = null;
            }),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats cards
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.power_off_rounded,
                    color: AppColors.error,
                    label: 'Total Power Cut',
                    value: _formatDuration(_totalDuration),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.equalizer_rounded,
                    color: AppColors.warning,
                    label: 'Avg Duration',
                    value: '${_avgDuration.toStringAsFixed(0)} min',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _StatCard(
              icon: Icons.info_outline_rounded,
              color: AppColors.primary,
              label: 'Total Events',
              value: '${events.length} cuts',
              fullWidth: true,
            ),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Power Cut History', style: AppTextStyles.headingMedium),
                GestureDetector(
                  onTap: _showFilterSheet,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.tune_rounded, color: AppColors.primary, size: 16),
                        const SizedBox(width: 6),
                        Text(_filterLabel, style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Chart
            Container(
              padding: const EdgeInsets.fromLTRB(8, 12, 12, 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: events.isEmpty
                  ? SizedBox(
                      height: 150,
                      child: Center(
                        child: Text(
                          'No data for selected period',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    )
                  : _buildChart(events),
            ),

            const SizedBox(height: 24),
            Text('Detailed Events', style: AppTextStyles.headingMedium),
            const SizedBox(height: 12),

            if (events.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'No power cut events found',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ),
              ),

            ...events.map((event) {
              final color = _getSeverityColor(event.severity);
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border(left: BorderSide(color: color, width: 4)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.power_off_rounded,
                          color: color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_fmtDate(event.date)}  •  ${_fmtTime(event.date)}',
                            style: AppTextStyles.labelLarge
                                .copyWith(color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Duration: ${_formatDuration(event.durationMinutes)}',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Chip(
                      label: Text(
                        event.severity.toUpperCase(),
                        style: AppTextStyles.labelSmall
                            .copyWith(color: AppColors.textPrimary),
                      ),
                      backgroundColor: color.withValues(alpha: 0.2),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(List<PowerCutEvent> events) {
    const chartH = 140.0;
    const yLabelW = 38.0;
    const barW = 26.0;
    const barSpacing = 10.0; // padding each side
    final itemW = barW + barSpacing * 2;

    final maxDur = events.map((e) => e.durationMinutes).reduce((a, b) => a > b ? a : b).toDouble();
    final yMax = ((maxDur / 60).ceil() * 60).toDouble();
    final ySteps = [0, (yMax * 0.25).round(), (yMax * 0.5).round(), (yMax * 0.75).round(), yMax.round()];

    final maxPower = events.map((e) => e.consumedPowerKw).reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Legend
        Row(
          children: [
            _legendDot(AppColors.error, 'Power Cut (min)'),
            const SizedBox(width: 16),
            _legendLine(Colors.cyanAccent, 'Consuming Power (kW)'),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Y-axis label + ticks
            Column(
              children: [
                SizedBox(
                  height: chartH,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      RotatedBox(
                        quarterTurns: 3,
                        child: const Text('Duration (min)', style: TextStyle(color: Colors.white38, fontSize: 9)),
                      ),
                      const SizedBox(width: 2),
                      SizedBox(
                        width: yLabelW,
                        height: chartH,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: ySteps.reversed.map((v) => Text('${v}m', style: const TextStyle(color: Colors.white38, fontSize: 9))).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
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
                        width: events.length * itemW,
                        child: Stack(
                          children: [
                            // Grid lines
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(5, (_) => Divider(height: 1, color: Colors.white.withValues(alpha: 0.07))),
                            ),
                            // Bars
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: events.map((event) {
                                final barH = (event.durationMinutes / yMax) * chartH;
                                final color = _getSeverityColor(event.severity);
                                return SizedBox(
                                  width: itemW,
                                  height: chartH,
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Tooltip(
                                      message: '${_fmtDate(event.date)} ${_fmtTime(event.date)}\nDuration: ${event.durationMinutes} min\nPower: ${event.consumedPowerKw} kW',
                                      child: Container(
                                        width: barW,
                                        height: barH,
                                        decoration: BoxDecoration(
                                          color: color.withValues(alpha: 0.8),
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            // Power line overlay
                            CustomPaint(
                              size: Size(events.length * itemW, chartH),
                              painter: _LinePainter(
                                events: events,
                                maxPower: maxPower,
                                chartH: chartH,
                                itemW: itemW,
                                color: Colors.cyanAccent,
                              ),
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
                        children: events.map((event) {
                          final xLabel = _filter == PowerCutFilter.today
                              ? _fmtTime(event.date)
                              : '${event.date.day}/${event.date.month}';
                          return SizedBox(
                            width: itemW,
                            child: Text(xLabel, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white38, fontSize: 9)),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _filter == PowerCutFilter.today ? 'Time of Day' : 'Date (DD/MM)',
                    style: const TextStyle(color: Colors.white38, fontSize: 9),
                  ),
                ],
              ),
            ),
            // Right Y-axis for power
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Column(
                children: [
                  SizedBox(
                    width: 36,
                    height: chartH,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(5, (i) {
                        final v = maxPower * (1 - i / 4);
                        return Text('${v.toStringAsFixed(1)}kW', style: const TextStyle(color: Colors.cyanAccent, fontSize: 8));
                      }),
                    ),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _legendDot(Color color, String label) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
    ],
  );

  Widget _legendLine(Color color, String label) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(width: 18, height: 2, color: color),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
    ],
  );

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'high':
        return AppColors.error;
      case 'medium':
        return AppColors.warning;
      default:
        return AppColors.success;
    }
  }

  String _formatDuration(int minutes) {
    return '${minutes ~/ 60} Hours ${minutes % 60} minutes';
  }

  String _fmt(DateTime d) => '${d.day}/${d.month}/${d.year}';

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _fmtTime(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}


class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final bool fullWidth;

  const _StatCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(label,
              style: TextStyle(color: Colors.white60, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
