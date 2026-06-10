/// A data point used for drawing charts.
/// Each point represents one time slice on the X axis.
class ChartDataPoint {
  final DateTime time;
  final double value;

  const ChartDataPoint({required this.time, required this.value});

  /// Generates a list of demo data points for the last [hours] hours.
  static List<ChartDataPoint> demoSolar({int hours = 24}) {
    final now = DateTime.now();
    // Simulate a solar bell curve peaking at noon
    return List.generate(hours, (i) {
      final hour = now.subtract(Duration(hours: hours - 1 - i));
      final h = hour.hour.toDouble();
      // Bell curve: peaks at 12:00, zero before 6 and after 20
      final value = (h >= 6 && h <= 20)
          ? 4000 * _bell(h, peak: 13, width: 5)
          : 0.0;
      return ChartDataPoint(time: hour, value: value);
    });
  }

  static double _bell(double x, {required double peak, required double width}) {
    final exponent = -((x - peak) * (x - peak)) / (2 * width * width);
    return _exp(exponent);
  }

  // Simple exp approximation without dart:math import
  static double _exp(double x) {
    // Use Dart's built-in via identical trick
    return x < -10 ? 0.0 : (1.0 + x + x * x / 2 + x * x * x / 6).clamp(0.0, 1.0);
  }
}
