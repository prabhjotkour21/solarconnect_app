import 'package:flutter/material.dart';
import '../models/power_cut_data.dart';
import '../services/service_locator.dart';
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
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _errorMessage;
  String? _inverterId;

  final List<PowerCutEvent> _allEvents = [];

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
      case PowerCutFilter.today:
        return 'Today';
      case PowerCutFilter.weekly:
        return 'Weekly';
      case PowerCutFilter.monthly:
        return 'Monthly';
      case PowerCutFilter.allTime:
        return 'All Time';
      case PowerCutFilter.custom:
        return _customRange != null
            ? '${_fmt(_customRange!.start)} - ${_fmt(_customRange!.end)}'
            : 'Custom';
    }
  }

  @override
  void initState() {
    super.initState();
    _loadPowerCutHistory();
  }

  Future<void> _loadPowerCutHistory({bool refreshing = false}) async {
    if (refreshing) {
      setState(() {
        _isRefreshing = true;
      });
    } else {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    final token = await ServiceLocator.instance.authService.getStoredToken();
    if (token == null || token.isEmpty) {
      setState(() {
        _errorMessage = 'Authentication required. Please login again.';
        _isLoading = false;
        _isRefreshing = false;
      });
      return;
    }

    try {
      final inverterResponse = await ServiceLocator.instance.inverterService.getInverters(token);
      final rawInverters = inverterResponse['data'] ?? inverterResponse;
      String? inverterId;

      if (rawInverters is List && rawInverters.isNotEmpty) {
        final firstInverter = rawInverters.first;
        if (firstInverter is Map<String, dynamic>) {
          inverterId = firstInverter['_id']?.toString() ?? firstInverter['id']?.toString();
        } else if (firstInverter is Map) {
          inverterId = firstInverter['_id']?.toString() ?? firstInverter['id']?.toString();
        }
      }

      if (inverterId == null || inverterId.isEmpty) {
        setState(() {
          _errorMessage = 'No paired inverter found. Please pair an inverter first.';
          _isLoading = false;
          _isRefreshing = false;
        });
        return;
      }

      final response = await ServiceLocator.instance.powerCutService.getPowerCuts(
        inverterId,
        token,
        queryParams: {'limit': 100},
      );

      final rawData = response['data'];
      final events = <PowerCutEvent>[];
      if (rawData is List) {
        for (final item in rawData) {
          if (item is Map<String, dynamic>) {
            events.add(PowerCutEvent.fromJson(item));
          } else if (item is Map) {
            events.add(PowerCutEvent.fromJson(Map<String, dynamic>.from(item)));
          }
        }
      }

      setState(() {
        _inverterId = inverterId;
        _allEvents
          ..clear()
          ..addAll(events);
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _allEvents.clear();
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
        _isRefreshing = false;
      });
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
                width: 40,
                height: 4,
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: AppColors.error),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => _loadPowerCutHistory(),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => _loadPowerCutHistory(refreshing: true),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_inverterId != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              'Inverter: $_inverterId',
                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                            ),
                          ),
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
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
                                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
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
                                        style: AppTextStyles.labelLarge.copyWith(color: AppColors.textPrimary),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Duration: ${_formatDuration(event.durationMinutes)}',
                                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                                Chip(
                                  label: Text(
                                    event.severity.toUpperCase(),
                                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.textPrimary),
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
                ),
    );
  }

  Widget _buildChart(List<PowerCutEvent> events) {
    const chartH = 160.0;
    const yLabelW = 36.0;
    const itemW = 46.0;

    final consumedVals = events.map((e) => e.consumedPowerKw).toList();
    final solarVals    = events.map((e) => e.solarPowerKw).toList();

    // Use a shared Y-max so both lines are on the same scale
    final allVals = [...consumedVals, ...solarVals];
    final dataMax = allVals.reduce((a, b) => a > b ? a : b);
    final yMax = dataMax * 1.25; // 25% headroom

    final ySteps = List.generate(5, (i) => yMax * (1 - i / 4));

    // Colors — clearly distinct
    const consumedColor = Color(0xFFFF6B35); // vivid orange
    const solarColor    = Color(0xFF00E676); // bright green

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Legend
        Wrap(
          spacing: 16,
          runSpacing: 4,
          children: [
            _legendLine(consumedColor, 'Consuming Power (kW)'),
            _legendDash(solarColor, 'Solar Generated (kW)'),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Y-axis
            Column(
              children: [
                SizedBox(
                  height: chartH,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      RotatedBox(
                        quarterTurns: 3,
                        child: const Text(
                          'Power (kW)',
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
                          children: ySteps
                              .map((v) => Text(
                                    v.toStringAsFixed(1),
                                    style: const TextStyle(
                                        color: Colors.white38, fontSize: 9),
                                  ))
                              .toList(),
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
                            // Horizontal grid lines
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
                            // Solar Generated — dashed green, filled
                            CustomPaint(
                              size: Size(events.length * itemW, chartH),
                              painter: _LinePainter(
                                values: solarVals,
                                yMax: yMax,
                                chartH: chartH,
                                itemW: itemW,
                                color: solarColor,
                                filled: true,
                                dashed: true,
                              ),
                            ),
                            // Consuming Power — solid orange, filled
                            CustomPaint(
                              size: Size(events.length * itemW, chartH),
                              painter: _LinePainter(
                                values: consumedVals,
                                yMax: yMax,
                                chartH: chartH,
                                itemW: itemW,
                                color: consumedColor,
                                filled: true,
                                dashed: false,
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
                            child: Text(
                              xLabel,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.white38, fontSize: 9),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _filter == PowerCutFilter.today
                        ? 'Time of Day'
                        : 'Date (DD/MM)',
                    style:
                        const TextStyle(color: Colors.white38, fontSize: 9),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _legendLine(Color color, String label) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(width: 18, height: 2, color: color),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
    ],
  );

  Widget _legendDash(Color color, String label) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      ...List.generate(3, (_) => Row(
        children: [
          Container(width: 5, height: 2, color: color),
          const SizedBox(width: 2),
        ],
      )),
      const SizedBox(width: 2),
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

// ── Line painter for power overlay lines ──────────────────────────────────────
class _LinePainter extends CustomPainter {
  final List<double> values;   // actual data points to plot
  final double yMax;           // top of the Y scale
  final double chartH;
  final double itemW;
  final Color color;
  final bool filled;           // whether to fill area under the line
  final bool dashed;

  const _LinePainter({
    required this.values,
    required this.yMax,
    required this.chartH,
    required this.itemW,
    required this.color,
    this.filled = false,
    this.dashed = false,
  });

  Offset _pointAt(int i) {
    final x = i * itemW + itemW / 2;
    final ratio = yMax > 0 ? (values[i] / yMax).clamp(0.0, 1.0) : 0.0;
    final y = chartH - ratio * (chartH - 8);
    return Offset(x, y);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    // ── filled area under the line ──
    if (filled) {
      final fillPath = Path();
      fillPath.moveTo(_pointAt(0).dx, chartH);
      for (int i = 0; i < values.length; i++) {
        fillPath.lineTo(_pointAt(i).dx, _pointAt(i).dy);
      }
      fillPath.lineTo(_pointAt(values.length - 1).dx, chartH);
      fillPath.close();
      canvas.drawPath(
        fillPath,
        Paint()
          ..color = color.withOpacity(0.15)
          ..style = PaintingStyle.fill,
      );
    }

    // ── line path ──
    final linePath = Path();
    linePath.moveTo(_pointAt(0).dx, _pointAt(0).dy);
    for (int i = 1; i < values.length; i++) {
      linePath.lineTo(_pointAt(i).dx, _pointAt(i).dy);
    }

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (dashed) {
      _drawDashed(canvas, linePath, linePaint);
    } else {
      canvas.drawPath(linePath, linePaint);
    }

    // ── dots at each data point ──
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final dotRing = Paint()
      ..color = Colors.black.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (int i = 0; i < values.length; i++) {
      final p = _pointAt(i);
      canvas.drawCircle(p, 4.0, dotPaint);
      canvas.drawCircle(p, 4.0, dotRing);
    }
  }

  void _drawDashed(Canvas canvas, Path path, Paint paint) {
    const dashLen = 7.0;
    const gapLen = 4.0;
    for (final metric in path.computeMetrics()) {
      double dist = 0.0;
      bool draw = true;
      while (dist < metric.length) {
        final seg = draw ? dashLen : gapLen;
        final end = (dist + seg).clamp(0.0, metric.length);
        if (draw) canvas.drawPath(metric.extractPath(dist, end), paint);
        dist += seg;
        draw = !draw;
      }
    }
  }

  @override
  bool shouldRepaint(_LinePainter old) =>
      old.values != values || old.yMax != yMax || old.color != color;
}
