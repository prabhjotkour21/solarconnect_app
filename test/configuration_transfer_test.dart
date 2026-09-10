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

  test('evaluates device readiness based on active, connected, ready, and busy states', () {
    expect(TransferDeviceStatusEvaluator.evaluate({'status': 'active', 'connectionStatus': 'online', 'isReady': true}).isReady, isTrue);
    expect(TransferDeviceStatusEvaluator.evaluate({'status': 'busy', 'connectionStatus': 'online', 'isReady': false}).isReady, isFalse);
    expect(TransferDeviceStatusEvaluator.evaluate({'status': 'inactive', 'connectionStatus': 'offline'}).message,
        contains('inactive'));
    expect(TransferDeviceStatusEvaluator.evaluate({'status': 'active', 'connectionStatus': 'connected', 'isReady': false}).message,
        contains('busy'));
  });

  test('maps rejected transfer reasons to user-friendly messages and retryability', () {
    final busy = TransferFailureReason.fromCode('DEVICE_BUSY');
    expect(busy.code, 'DEVICE_BUSY');
    expect(busy.isRetryable, isTrue);
    expect(busy.message, contains('busy'));

    final storage = TransferFailureReason.fromCode('INSUFFICIENT_STORAGE');
    expect(storage.isRetryable, isFalse);
    expect(storage.message, contains('storage'));

    final size = TransferFailureReason.fromCode('FILE_TOO_LARGE');
    expect(size.message, contains('too large'));
  });

  test('implements retry attempts with exponential backoff and max 3 attempts', () {
    final policy = TransferRetryPolicy();
    expect(policy.maxAttempts, 3);
    expect(policy.delayForAttempt(1), 1000);
    expect(policy.delayForAttempt(2), 2000);
    expect(policy.delayForAttempt(3), 4000);
    expect(policy.shouldRetry(TransferFailureReason.fromCode('NETWORK_TIMEOUT')), isTrue);
    expect(policy.shouldRetry(TransferFailureReason.fromCode('CHECKSUM_MISMATCH')), isFalse);
  });
}
