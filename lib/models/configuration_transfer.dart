enum ConfigurationTransferStatus {
  idle,
  generating,
  waitingForDevice,
  transferring,
  verifying,
  completed,
  paused,
  failed,
  retryPending,
}

extension ConfigurationTransferStatusLabel on ConfigurationTransferStatus {
  String get label {
    switch (this) {
      case ConfigurationTransferStatus.idle:
        return 'Ready';
      case ConfigurationTransferStatus.generating:
        return 'Generating configuration';
      case ConfigurationTransferStatus.waitingForDevice:
        return 'Waiting for ESP32';
      case ConfigurationTransferStatus.transferring:
        return 'Transferring';
      case ConfigurationTransferStatus.verifying:
        return 'Verifying checksum';
      case ConfigurationTransferStatus.completed:
        return 'Completed';
      case ConfigurationTransferStatus.paused:
        return 'Paused';
      case ConfigurationTransferStatus.failed:
        return 'Failed';
      case ConfigurationTransferStatus.retryPending:
        return 'Retry pending';
    }
  }
}

class GeneratedConfigurationFile {
  const GeneratedConfigurationFile({
    required this.fileId,
    required this.fileName,
    required this.fileSize,
    required this.totalChunks,
    required this.chunkSize,
    required this.checksum,
    required this.payload,
    this.fileType = 'parameter_config',
  });

  final String fileId;
  final String fileName;
  final int fileSize;
  final int totalChunks;
  final int chunkSize;
  final String checksum;
  final String payload;
  final String fileType;

  factory GeneratedConfigurationFile.fromJson(Map<String, dynamic> json) {
    int number(dynamic value) => value is num ? value.toInt() : int.tryParse('$value') ?? 0;
    return GeneratedConfigurationFile(
      fileId: '${json['fileId'] ?? ''}',
      fileName: '${json['fileName'] ?? 'configuration.bin'}',
      fileSize: number(json['fileSize']),
      totalChunks: number(json['totalChunks']),
      chunkSize: number(json['chunkSize']),
      checksum: '${json['checksum'] ?? ''}',
      payload: '${json['payload'] ?? ''}',
      fileType: '${json['fileType'] ?? 'parameter_config'}',
    );
  }

  double get sizeInKilobytes => fileSize / 1024;
}

class TransferDeviceStatusEvaluation {
  const TransferDeviceStatusEvaluation({
    required this.isReady,
    required this.isActive,
    required this.isConnected,
    required this.isBusy,
    required this.message,
    this.failureCode,
  });

  final bool isReady;
  final bool isActive;
  final bool isConnected;
  final bool isBusy;
  final String message;
  final String? failureCode;

  static TransferDeviceStatusEvaluation evaluate(Map<String, dynamic> status) {
    final rawStatus = (status['status'] ?? status['deviceStatus'] ?? status['state'] ?? '').toString().toLowerCase();
    final rawConnection = (status['connectionStatus'] ?? status['deviceConnectionStatus'] ?? '').toString().toLowerCase();
    final isActive = status['isActive'] == true || status['active'] == true || rawStatus == 'active';
    final isConnected = status['isOnline'] == true || status['connected'] == true || rawConnection == 'online' || rawConnection == 'connected';
    final isReadyForTransfer = status['isReady'] == true || status['ready'] == true || rawStatus == 'ready';
    final isBusy = status['isBusy'] == true || status['busy'] == true || rawStatus == 'busy';

    if (isBusy) {
      return const TransferDeviceStatusEvaluation(
        isReady: false,
        isActive: true,
        isConnected: true,
        isBusy: true,
        message: 'The ESP32 is currently busy. Please wait for the current task to finish and retry.',
        failureCode: 'DEVICE_BUSY',
      );
    }

    if (!isActive) {
      return const TransferDeviceStatusEvaluation(
        isReady: false,
        isActive: false,
        isConnected: false,
        isBusy: false,
        message: 'The ESP32 is inactive. Activate the device and reconnect before starting a file transfer.',
        failureCode: 'DEVICE_INACTIVE',
      );
    }

    if (!isConnected) {
      return const TransferDeviceStatusEvaluation(
        isReady: false,
        isActive: true,
        isConnected: false,
        isBusy: false,
        message: 'The ESP32 is not connected. Check the Wi-Fi or Bluetooth connection and retry.',
        failureCode: 'TEMPORARY_DISCONNECTION',
      );
    }

    if (!isReadyForTransfer) {
      return const TransferDeviceStatusEvaluation(
        isReady: false,
        isActive: true,
        isConnected: true,
        isBusy: false,
        message: 'The ESP32 is not ready to receive a file yet. Wait until its transfer state is clear.',
        failureCode: 'DEVICE_NOT_READY',
      );
    }

    return const TransferDeviceStatusEvaluation(
      isReady: true,
      isActive: true,
      isConnected: true,
      isBusy: false,
      message: 'The ESP32 is ready for transfer.',
    );
  }
}

class TransferDeviceStatusEvaluator {
  static TransferDeviceStatusEvaluation evaluate(Map<String, dynamic> status) =>
      TransferDeviceStatusEvaluation.evaluate(status);
}

class TransferFailureReason {
  const TransferFailureReason({
    required this.code,
    required this.message,
    required this.isRetryable,
    this.requiresManualAction = false,
  });

  final String code;
  final String message;
  final bool isRetryable;
  final bool requiresManualAction;

  factory TransferFailureReason.fromCode(String? code) {
    final normalized = (code ?? '').trim().toUpperCase();
    switch (normalized) {
      case 'DEVICE_BUSY':
        return const TransferFailureReason(
          code: 'DEVICE_BUSY',
          message: 'The ESP32 is busy and cannot accept a new file right now.',
          isRetryable: true,
        );
      case 'FILE_TOO_LARGE':
        return const TransferFailureReason(
          code: 'FILE_TOO_LARGE',
          message: 'The configuration file is too large for the ESP32 storage.',
          isRetryable: false,
        );
      case 'INVALID_FILE_TYPE':
        return const TransferFailureReason(
          code: 'INVALID_FILE_TYPE',
          message: 'The uploaded file type is invalid for this device configuration transfer.',
          isRetryable: false,
        );
      case 'DEVICE_INACTIVE':
        return const TransferFailureReason(
          code: 'DEVICE_INACTIVE',
          message: 'The device is inactive and cannot receive a configuration update.',
          isRetryable: false,
        );
      case 'NETWORK_TIMEOUT':
        return const TransferFailureReason(
          code: 'NETWORK_TIMEOUT',
          message: 'The network timed out while transmitting the configuration file.',
          isRetryable: true,
        );
      case 'ESP32_RESPONSE_TIMEOUT':
        return const TransferFailureReason(
          code: 'ESP32_RESPONSE_TIMEOUT',
          message: 'The ESP32 did not respond in time to the transfer request.',
          isRetryable: true,
        );
      case 'TEMPORARY_DISCONNECTION':
        return const TransferFailureReason(
          code: 'TEMPORARY_DISCONNECTION',
          message: 'The device connection dropped briefly, and the transfer will retry automatically.',
          isRetryable: true,
        );
      case 'SIZE_MISMATCH':
        return const TransferFailureReason(
          code: 'SIZE_MISMATCH',
          message: 'The received file size does not match the expected transfer size.',
          isRetryable: false,
          requiresManualAction: true,
        );
      case 'CHECKSUM_MISMATCH':
        return const TransferFailureReason(
          code: 'CHECKSUM_MISMATCH',
          message: 'The transmitted file checksum does not match the expected checksum.',
          isRetryable: false,
          requiresManualAction: true,
        );
      case 'OUT_OF_RANGE':
        return const TransferFailureReason(
          code: 'OUT_OF_RANGE',
          message: 'One or more parameter values are outside the valid range for this device.',
          isRetryable: false,
          requiresManualAction: true,
        );
      case 'INSUFFICIENT_STORAGE':
        return const TransferFailureReason(
          code: 'INSUFFICIENT_STORAGE',
          message: 'The ESP32 does not have enough storage remaining to accept the new configuration.',
          isRetryable: false,
          requiresManualAction: true,
        );
      default:
        return const TransferFailureReason(
          code: 'TRANSFER_FAILED',
          message: 'The configuration transfer failed. Please check the device status and retry.',
          isRetryable: true,
        );
    }
  }
}

class TransferRetryPolicy {
  static const int maxAttempts = 3;
  static const int baseDelayMs = 1000;

  int get maxAttempts => TransferRetryPolicy.maxAttempts;

  int delayForAttempt(int attempt) {
    if (attempt <= 1) return baseDelayMs;
    return baseDelayMs * (1 << (attempt - 1));
  }

  bool shouldRetry(TransferFailureReason reason) {
    return reason.isRetryable && reason.code != 'DEVICE_INACTIVE' && reason.code != 'FILE_TOO_LARGE' && reason.code != 'INVALID_FILE_TYPE';
  }
}

class TransferErrorHistoryEntry {
  const TransferErrorHistoryEntry({
    required this.code,
    required this.message,
    required this.timestamp,
  });

  final String code;
  final String message;
  final DateTime timestamp;
}

