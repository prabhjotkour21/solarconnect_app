class EnvironmentalData {
  final double treeEquivalent;
  final double co2Saved; // in kg
  final double fuelSaved; // in liters
  final double waterSaved; // in liters

  EnvironmentalData({
    required this.treeEquivalent,
    required this.co2Saved,
    required this.fuelSaved,
    required this.waterSaved,
  });

  static EnvironmentalData demo() {
    return EnvironmentalData(
      treeEquivalent: 0.81,
      co2Saved: 48.64,
      fuelSaved: 15.2,
      waterSaved: 125.8,
    );
  }

  // Calculate based on generation in kWh
  static EnvironmentalData fromGeneration(double kwhGenerated) {
    return EnvironmentalData(
      treeEquivalent: kwhGenerated * 0.18,
      co2Saved: kwhGenerated * 10.82,
      fuelSaved: kwhGenerated * 3.38,
      waterSaved: kwhGenerated * 28.0,
    );
  }
}
