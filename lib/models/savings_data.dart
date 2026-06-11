class SavingsData {
  final double totalSavings; // in rupees
  final double dailyAverage;
  final double lastMonthSavings;
  final double roi; // return on investment %
  final double investmentAmount;
  final int roi_months; // months to break even

  SavingsData({
    required this.totalSavings,
    required this.dailyAverage,
    required this.lastMonthSavings,
    required this.roi,
    required this.investmentAmount,
    required this.roi_months,
  });

  static SavingsData demo() {
    return SavingsData(
      totalSavings: 145,
      dailyAverage: 48,
      lastMonthSavings: 54,
      roi: 8.36,
      investmentAmount: 1740,
      roi_months: 36,
    );
  }

  String get roiMonthsDisplay {
    if (roi_months < 12) {
      return '$roi_months months';
    } else {
      int years = roi_months ~/ 12;
      int months = roi_months % 12;
      if (months == 0) {
        return '$years years';
      }
      return '$years years $months months';
    }
  }
}
