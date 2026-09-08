import 'package:flutter_test/flutter_test.dart';
import 'package:solarconnect_app/models/configuration_transfer.dart';

void main() {
  test('parses generated configuration metadata and payload', () {
    final file = GeneratedConfigurationFile.fromJson({
      'fileId': 'cfg-1',
      'fileName': 'cfg-1.bin',
      'fileSize': 8192,
      'totalChunks': 2,
      'chunkSize': 4096,
      'checksum': 'abcdef1234567890abcdef1234567890',
      'payload': 'AQI=',
    });

    expect(file.fileName, 'cfg-1.bin');
    expect(file.fileSize, 8192);
    expect(file.totalChunks, 2);
    expect(file.sizeInKilobytes, 8);
    expect(file.fileType, 'parameter_config');
  });

  test('exposes user-facing labels for every transfer state', () {
    for (final state in ConfigurationTransferStatus.values) {
      expect(state.label, isNotEmpty);
    }
    expect(ConfigurationTransferStatus.waitingForDevice.label, 'Waiting for ESP32');
    expect(ConfigurationTransferStatus.retryPending.label, 'Retry pending');
  });
}
