class TrendDataPoint {
  final DateTime time;
  final double value; // in kW
  final String label;

  TrendDataPoint({
    required this.time,
    required this.value,
    required this.label,
  });
}

class TrendData {
  final List<TrendDataPoint> hourlyData;
  final List<TrendDataPoint> dailyData;
  final List<TrendDataPoint> monthlyData;
  final double totalGeneration; // kWh

  TrendData({
    required this.hourlyData,
    required this.dailyData,
    required this.monthlyData,
    required this.totalGeneration,
  });

  static TrendData demo() {
    return TrendData(
      hourlyData: [
        TrendDataPoint(time: DateTime.now().subtract(const Duration(hours: 5)), value: 0.0, label: '11:29 am'),
        TrendDataPoint(time: DateTime.now().subtract(const Duration(hours: 4)), value: 0.8, label: '12:00 pm'),
        TrendDataPoint(time: DateTime.now().subtract(const Duration(hours: 3)), value: 1.2, label: '1:00 pm'),
        TrendDataPoint(time: DateTime.now().subtract(const Duration(hours: 2)), value: 1.42, label: '2:00 pm'),
        TrendDataPoint(time: DateTime.now().subtract(const Duration(hours: 1)), value: 0.9, label: '3:00 pm'),
        TrendDataPoint(time: DateTime.now(), value: 0.5, label: '4:00 pm'),
      ],
      dailyData: [
        TrendDataPoint(time: DateTime.now().subtract(const Duration(days: 5)), value: 3.2, label: '22-Sep'),
        TrendDataPoint(time: DateTime.now().subtract(const Duration(days: 4)), value: 2.8, label: '23-Sep'),
        TrendDataPoint(time: DateTime.now().subtract(const Duration(days: 3)), value: 3.5, label: '24-Sep'),
        TrendDataPoint(time: DateTime.now().subtract(const Duration(days: 2)), value: 2.1, label: '25-Sep'),
        TrendDataPoint(time: DateTime.now().subtract(const Duration(days: 1)), value: 1.9, label: '26-Sep'),
        TrendDataPoint(time: DateTime.now(), value: 4.5, label: '27-Sep'),
      ],
      monthlyData: [
        TrendDataPoint(time: DateTime.now().subtract(const Duration(days: 60)), value: 85.0, label: 'Jul'),
        TrendDataPoint(time: DateTime.now().subtract(const Duration(days: 30)), value: 92.0, label: 'Aug'),
        TrendDataPoint(time: DateTime.now(), value: 98.5, label: 'Sep'),
      ],
      totalGeneration: 4.5,
    );
  }
}
