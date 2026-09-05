import '../models/device_parameter.dart';

abstract final class ParameterValidationMessages {
  static const required = 'This field is required.';
  static const invalidInteger = 'Enter a valid integer.';
  static const invalidFloat = 'Enter a valid number.';
  static const invalidBoolean = 'Enter true or false.';
  static const invalidValue = 'Enter a valid value.';
  static const belowMinimum = 'Value is below the minimum allowed.';
  static const aboveMaximum = 'Value is above the maximum allowed.';
}

abstract final class ParameterValidator {
  static String? validate(DeviceParameter parameter, String text) {
    final value = text.trim();
    if (value.isEmpty) {
      return parameter.isRequired ? ParameterValidationMessages.required : null;
    }

    final type = parameter.dataType.toUpperCase();
    num? numericValue;
    if (_isInteger(type)) {
      final parsed = int.tryParse(value);
      if (parsed == null) return ParameterValidationMessages.invalidInteger;
      numericValue = parsed;
    } else if (_isFloat(type)) {
      final parsed = double.tryParse(value);
      if (parsed == null || !parsed.isFinite) return ParameterValidationMessages.invalidFloat;
      numericValue = parsed;
    } else if (_isBoolean(type)) {
      if (value.toLowerCase() != 'true' && value.toLowerCase() != 'false') {
        return ParameterValidationMessages.invalidBoolean;
      }
    } else if (!_isString(type)) {
      return ParameterValidationMessages.invalidValue;
    }

    if (numericValue != null && parameter.minValue != null && numericValue < parameter.minValue!) {
      return '${ParameterValidationMessages.belowMinimum} Minimum: ${parameter.minValue}.';
    }
    if (numericValue != null && parameter.maxValue != null && numericValue > parameter.maxValue!) {
      return '${ParameterValidationMessages.aboveMaximum} Maximum: ${parameter.maxValue}.';
    }
    return null;
  }

  static bool _isInteger(String type) => type.startsWith('INT') || type.startsWith('UINT') || type == 'INTEGER';
  static bool _isFloat(String type) => type.startsWith('FLOAT') || type == 'DOUBLE' || type == 'DECIMAL';
  static bool _isBoolean(String type) => type == 'BOOL' || type == 'BOOLEAN';
  static bool _isString(String type) => type == 'STRING' || type == 'TEXT';
}
