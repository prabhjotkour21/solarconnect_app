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
}
