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
