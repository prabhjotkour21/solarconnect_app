class DeviceParameter {
  const DeviceParameter({required this.parameterNumber, required this.parameterName, required this.dataType, this.currentValue, this.lastSentValue, this.minValue, this.maxValue, this.unit, this.isRequired = false});
  final int parameterNumber;
  final String parameterName;
  final String dataType;
  final dynamic currentValue;
  final dynamic lastSentValue;
  final double? minValue;
  final double? maxValue;
  final String? unit;
  final bool isRequired;

  static DeviceParameter fromJson(Map<String, dynamic> json) {
    double? number(dynamic value) => value is num ? value.toDouble() : double.tryParse('$value');
    final validation = json['validation'];
    final validationMap = validation is Map ? validation : const <String, dynamic>{};
    final required = json['isRequired'] ?? json['required'] ?? validationMap['isRequired'] ?? validationMap['required'] ?? false;
    return DeviceParameter(
      parameterNumber: int.tryParse('${json['parameterNumber'] ?? 0}') ?? 0,
      parameterName: '${json['parameterName'] ?? 'Parameter'}',
      dataType: '${json['dataType'] ?? 'STRING'}',
      currentValue: json['currentValue'],
      lastSentValue: json['lastSentValue'],
      minValue: number(json['minValue']), maxValue: number(json['maxValue']), unit: json['unit']?.toString(), isRequired: required == true || required == 1 || required == 'true',
    );
  }
}