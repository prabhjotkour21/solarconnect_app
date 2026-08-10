/// A single solar energy reading captured at one point in time.
///
/// All power values are in Watts (W).
/// All energy values are in kilowatt-hours (kWh).
class EnergyReading {
  final DateTime timestamp;

  // ── Power (instantaneous, in Watts) ───────────────────────────────────────
  final double solarPowerW;       // How much the panels are generating right now
  final double consumptionPowerW; // How much the home is consuming right now
  final double batteryPowerW;     // Positive = charging, negative = discharging
  final double gridPowerW;        // Positive = importing, negative = exporting

  // ── Battery state ─────────────────────────────────────────────────────────
  final double batteryPercent;    // 0.0 to 100.0
  final bool batteryCharging;

  // ── Daily totals (in kWh) ─────────────────────────────────────────────────
  final double solarTodayKwh;
  final double consumptionTodayKwh;
  final double gridImportTodayKwh;
  final double gridExportTodayKwh;

  const EnergyReading({
    required this.timestamp,
    required this.solarPowerW,
    required this.consumptionPowerW,
    required this.batteryPowerW,
    required this.gridPowerW,
    required this.batteryPercent,
    required this.batteryCharging,
    required this.solarTodayKwh,
    required this.consumptionTodayKwh,
    required this.gridImportTodayKwh,
    required this.gridExportTodayKwh,
  });

  /// Returns a demo reading with realistic-looking values.
  /// Used during development before a real API is connected.
  factory EnergyReading.demo() => EnergyReading(
        timestamp: DateTime.now(),
        solarPowerW: 3450,
        consumptionPowerW: 1820,
        batteryPowerW: 800,
        gridPowerW: -830, // negative = exporting to grid
        batteryPercent: 72,
        batteryCharging: true,
        solarTodayKwh: 18.4,
        consumptionTodayKwh: 9.2,
        gridImportTodayKwh: 0.3,
        gridExportTodayKwh: 6.1,
      );

  factory EnergyReading.fromDashboardOverview(Map<String, dynamic> overview) {
    final currentReading = (overview['currentReading'] ?? {}) as Map<String, dynamic>;
    final todayStats = (overview['todayStats'] ?? {}) as Map<String, dynamic>;

    final double solarPowerW = _toDouble(currentReading['solarGenerated']);
    final double consumptionPowerW = _toDouble(currentReading['consumption']);
    final double gridPowerW = _toDouble(currentReading['gridSupply']);
    final double batteryPercent = _toDouble(currentReading['batteryLevel']);
    final bool batteryCharging = currentReading['inverterStatus']?.toString().toLowerCase() == 'charging' || batteryPercent >= 80;
    final double batteryPowerW = solarPowerW - consumptionPowerW - gridPowerW;

    final dateString = currentReading['timestamp']?.toString();
    final DateTime timestamp = dateString != null
        ? DateTime.tryParse(dateString) ?? DateTime.now()
        : DateTime.now();

    return EnergyReading(
      timestamp: timestamp,
      solarPowerW: solarPowerW,
      consumptionPowerW: consumptionPowerW,
      batteryPowerW: batteryPowerW,
      gridPowerW: gridPowerW,
      batteryPercent: batteryPercent.clamp(0, 100),
      batteryCharging: batteryCharging,
      solarTodayKwh: _toDouble(todayStats['totalGenerated']),
      consumptionTodayKwh: _toDouble(todayStats['totalConsumed']),
      gridImportTodayKwh: _toDouble(todayStats['totalGridSupply']),
      gridExportTodayKwh: 0.0,
    );
  }

  static double _toDouble(Object? value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
