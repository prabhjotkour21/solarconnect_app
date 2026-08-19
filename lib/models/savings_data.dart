class SavingsData {
  final double totalSavings; // in rupees
  final double dailyAverage;
  final double lastMonthSavings;
  final double roi; // return on investment %
  final double investmentAmount;
  final double roi_months; // months to break even

  SavingsData({
    required this.totalSavings,
    required this.dailyAverage,
    required this.lastMonthSavings,
    required this.roi,
    required this.investmentAmount,
    required this.roi_months,
  });

  static SavingsData fromApi(Map<String, dynamic> summary, {double investmentAmount = 0}) {
    final totalSavings = (summary['totalSavings'] ?? 0).toDouble();
    final dailyAverage = (summary['averageDailySavings'] ?? summary['totalSavings'] ?? 0).toDouble();
    final lastMonthSavings = (summary['lastPeriodSavings'] ?? summary['totalSavings'] ?? 0).toDouble();
    final roi = (summary['roi'] ?? 0).toDouble();
    final investment = investmentAmount > 0 ? investmentAmount : (summary['investmentAmount'] ?? 0).toDouble();
    final breakEven = (summary['breakEvenMonths'] ?? 0).toDouble();

    return SavingsData(
      totalSavings: totalSavings,
      dailyAverage: dailyAverage,
      lastMonthSavings: lastMonthSavings,
      roi: roi,
      investmentAmount: investment,
      roi_months: breakEven,
    );
  }

  String get roiMonthsDisplay {
    if (roi_months <= 0) {
      return 'Not available';
    }
    if (roi_months < 12) {
      if (roi_months < 1) {
        final days = (roi_months * 30).ceil();
        return '$days ${days == 1 ? 'day' : 'days'}';
      }
      return '${roi_months.toStringAsFixed(2)} months';
    } else {
      final totalMonths = roi_months.round();
      int years = totalMonths ~/ 12;
      int months = totalMonths % 12;
      if (months == 0) {
        return '$years years';
      }
      return '$years years $months months';
    }
  }
}
