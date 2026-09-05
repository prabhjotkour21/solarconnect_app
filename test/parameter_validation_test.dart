import 'package:flutter_test/flutter_test.dart';
import 'package:solarconnect_app/models/device_parameter.dart';
import 'package:solarconnect_app/validation/parameter_validation.dart';

DeviceParameter parameter(String type, {double? min, double? max, bool required = true}) => DeviceParameter(
  parameterNumber: 1,
  parameterName: 'Test parameter',
  dataType: type,
  minValue: min,
  maxValue: max,
  isRequired: required,
);

void main() {
  group('ParameterValidator', () {
    test('accepts integer boundaries and rejects non-integers', () {
      expect(ParameterValidator.validate(parameter('INT16', min: 0, max: 10), '0'), isNull);
      expect(ParameterValidator.validate(parameter('INT16', min: 0, max: 10), '10'), isNull);
      expect(ParameterValidator.validate(parameter('INT16'), '1.5'), ParameterValidationMessages.invalidInteger);
    });

    test('validates float values and range', () {
      expect(ParameterValidator.validate(parameter('FLOAT32', min: 1, max: 5), '2.5'), isNull);
      expect(ParameterValidator.validate(parameter('FLOAT32', min: 1), '0.9'), contains('Minimum: 1'));
      expect(ParameterValidator.validate(parameter('FLOAT32', max: 5), '5.1'), contains('Maximum: 5'));
    });

    test('validates strings and booleans', () {
      expect(ParameterValidator.validate(parameter('STRING'), 'hello'), isNull);
      expect(ParameterValidator.validate(parameter('BOOL'), 'true'), isNull);
      expect(ParameterValidator.validate(parameter('BOOL'), 'yes'), ParameterValidationMessages.invalidBoolean);
    });

    test('handles required and optional empty fields', () {
      expect(ParameterValidator.validate(parameter('STRING'), ''), ParameterValidationMessages.required);
      expect(ParameterValidator.validate(parameter('STRING', required: false), ''), isNull);
    });
  });
}
