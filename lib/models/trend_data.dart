class TrendDataPoint {
  final DateTime time;
  final double value; // solar kW
  final String label;
  final double sunlightHours; // hours of sunlight for this period

  TrendDataPoint({
    required this.time,
    required this.value,
    required this.label,
    this.sunlightHours = 0.0,
  });
}

class TrendData {
  final List<TrendDataPoint> hourlyData;
  final List<TrendDataPoint> dailyData;
  final List<TrendDataPoint> monthlyData;
  final List<TrendDataPoint> yearlyData;
  final double totalGeneration; // kWh

  TrendData({
    required this.hourlyData,
    required this.dailyData,
    required this.monthlyData,
    required this.yearlyData,
    required this.totalGeneration,
  });

  static TrendData demo() {
    final now = DateTime.now();
    return TrendData(
      hourlyData: [
        TrendDataPoint(time: now.subtract(const Duration(hours: 7)), value: 0.0,  label: '7AM',  sunlightHours: 0.2),
        TrendDataPoint(time: now.subtract(const Duration(hours: 6)), value: 0.3,  label: '8AM',  sunlightHours: 0.8),
        TrendDataPoint(time: now.subtract(const Duration(hours: 5)), value: 0.8,  label: '9AM',  sunlightHours: 1.0),
        TrendDataPoint(time: now.subtract(const Duration(hours: 4)), value: 1.2,  label: '10AM', sunlightHours: 1.0),
        TrendDataPoint(time: now.subtract(const Duration(hours: 3)), value: 1.5,  label: '11AM', sunlightHours: 1.0),
        TrendDataPoint(time: now.subtract(const Duration(hours: 2)), value: 1.42, label: '12PM', sunlightHours: 1.0),
        TrendDataPoint(time: now.subtract(const Duration(hours: 1)), value: 0.9,  label: '3PM',  sunlightHours: 0.9),
        TrendDataPoint(time: now,                                    value: 0.5,  label: '4PM',  sunlightHours: 0.6),
      ],
      dailyData: [
        TrendDataPoint(time: now.subtract(const Duration(days: 6)), value: 3.2, label: 'Mon', sunlightHours: 7.2),
        TrendDataPoint(time: now.subtract(const Duration(days: 5)), value: 2.8, label: 'Tue', sunlightHours: 6.5),
        TrendDataPoint(time: now.subtract(const Duration(days: 4)), value: 3.5, label: 'Wed', sunlightHours: 8.1),
        TrendDataPoint(time: now.subtract(const Duration(days: 3)), value: 2.1, label: 'Thu', sunlightHours: 5.3),
        TrendDataPoint(time: now.subtract(const Duration(days: 2)), value: 1.9, label: 'Fri', sunlightHours: 4.8),
        TrendDataPoint(time: now.subtract(const Duration(days: 1)), value: 4.5, label: 'Sat', sunlightHours: 9.0),
        TrendDataPoint(time: now,                                   value: 3.8, label: 'Sun', sunlightHours: 8.4),
      ],
      monthlyData: [
        TrendDataPoint(time: now.subtract(const Duration(days: 330)), value: 62.0,  label: 'Jan', sunlightHours: 4.1),
        TrendDataPoint(time: now.subtract(const Duration(days: 300)), value: 70.0,  label: 'Feb', sunlightHours: 5.0),
        TrendDataPoint(time: now.subtract(const Duration(days: 270)), value: 88.0,  label: 'Mar', sunlightHours: 6.8),
        TrendDataPoint(time: now.subtract(const Duration(days: 240)), value: 95.0,  label: 'Apr', sunlightHours: 7.9),
        TrendDataPoint(time: now.subtract(const Duration(days: 210)), value: 110.0, label: 'May', sunlightHours: 9.2),
        TrendDataPoint(time: now.subtract(const Duration(days: 180)), value: 118.0, label: 'Jun', sunlightHours: 9.8),
        TrendDataPoint(time: now.subtract(const Duration(days: 150)), value: 115.0, label: 'Jul', sunlightHours: 9.5),
        TrendDataPoint(time: now.subtract(const Duration(days: 120)), value: 105.0, label: 'Aug', sunlightHours: 8.7),
        TrendDataPoint(time: now.subtract(const Duration(days: 90)),  value: 98.5,  label: 'Sep', sunlightHours: 7.6),
        TrendDataPoint(time: now.subtract(const Duration(days: 60)),  value: 80.0,  label: 'Oct', sunlightHours: 6.2),
        TrendDataPoint(time: now.subtract(const Duration(days: 30)),  value: 58.0,  label: 'Nov', sunlightHours: 4.5),
        TrendDataPoint(time: now,                                      value: 50.0,  label: 'Dec', sunlightHours: 3.8),
      ],
      yearlyData: [
        TrendDataPoint(time: now.subtract(const Duration(days: 365 * 4)), value: 820.0,  label: '2021', sunlightHours: 5.8),
        TrendDataPoint(time: now.subtract(const Duration(days: 365 * 3)), value: 890.0,  label: '2022', sunlightHours: 6.2),
        TrendDataPoint(time: now.subtract(const Duration(days: 365 * 2)), value: 950.0,  label: '2023', sunlightHours: 6.7),
        TrendDataPoint(time: now.subtract(const Duration(days: 365)),     value: 1020.0, label: '2024', sunlightHours: 7.1),
        TrendDataPoint(time: now,                                          value: 680.0,  label: '2025', sunlightHours: 6.4),
      ],
      totalGeneration: 4.5,
    );
  }
}
