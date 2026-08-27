import 'package:flutter/services.dart';
import 'package:wifi_scan/wifi_scan.dart';

class WifiNetwork {
  const WifiNetwork({
    required this.ssid,
    required this.signal,
    required this.isSecured,
  });

  final String ssid;
  final int signal;
  final bool isSecured;
}

class WifiNetworkService {
  Future<List<WifiNetwork>> scanNetworks() async {
    try {
      final canScan = await WiFiScan.instance.canStartScan(askPermissions: true);
      if (canScan != CanStartScan.yes) {
        throw StateError('Wi-Fi scanning is unavailable. Enable Wi-Fi and location permissions, then try again.');
      }

      await WiFiScan.instance.startScan();
      final accessPoints = await WiFiScan.instance.getScannedResults();
      return _toNetworks(accessPoints);
    } on MissingPluginException {
      throw StateError('Wi-Fi scanner is not available in this app build. Stop the app and run a full Android rebuild.');
    }
  }

  List<WifiNetwork> _toNetworks(List<WiFiAccessPoint> accessPoints) {
    final networks = accessPoints
        .where((accessPoint) => accessPoint.ssid.trim().isNotEmpty)
        .map(
          (accessPoint) => WifiNetwork(
            ssid: accessPoint.ssid.trim(),
            signal: (((accessPoint.level + 100) / 70) * 100).round().clamp(0, 100),
            isSecured: accessPoint.capabilities.isNotEmpty,
          ),
        )
        .toList();

    final uniqueNetworks = <String, WifiNetwork>{};
    for (final network in networks) {
      final existing = uniqueNetworks[network.ssid];
      if (existing == null || network.signal > existing.signal) {
        uniqueNetworks[network.ssid] = network;
      }
    }

    final result = uniqueNetworks.values.toList()
      ..sort((first, second) => second.signal.compareTo(first.signal));
    return result;
  }
}