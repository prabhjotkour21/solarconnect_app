class InverterData {
  final String? serialNumber;
  final String? modelName;
  final String? firmwareVersion;
  final bool isPaired;
  final DateTime? pairedDate;

  InverterData({
    this.serialNumber,
    this.modelName,
    this.firmwareVersion,
    this.isPaired = false,
    this.pairedDate,
  });

  static InverterData demo() {
    return InverterData(
      serialNumber: '9AL1021Z100407',
      modelName: 'Hybrid SKVA',
      firmwareVersion: 'v2.1.4',
      isPaired: true,
      pairedDate: DateTime(2023, 9, 1),
    );
  }

  InverterData copyWith({
    String? serialNumber,
    String? modelName,
    String? firmwareVersion,
    bool? isPaired,
    DateTime? pairedDate,
  }) {
    return InverterData(
      serialNumber: serialNumber ?? this.serialNumber,
      modelName: modelName ?? this.modelName,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      isPaired: isPaired ?? this.isPaired,
      pairedDate: pairedDate ?? this.pairedDate,
    );
  }
}
