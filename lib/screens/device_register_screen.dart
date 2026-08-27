import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/service_locator.dart';
import '../services/wifi_network_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/app_constants.dart';
import '../utils/app_dialogs.dart';

class DeviceRegisterScreen extends StatefulWidget {
  const DeviceRegisterScreen({super.key});

  @override
  State<DeviceRegisterScreen> createState() => _DeviceRegisterScreenState();
}

class _DeviceRegisterScreenState extends State<DeviceRegisterScreen> {
  final TextEditingController _serialController = TextEditingController();
  final TextEditingController _macController = TextEditingController();
  final TextEditingController _firmwareController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isRegistering = false;
  String? _message;
  // Provisioning state
  String? _deviceId;
  String? _deviceToken;
  final TextEditingController _wifiSsidController = TextEditingController();
  final TextEditingController _wifiPasswordController = TextEditingController();
  bool _isProvisioning = false;
  final _wifiNetworkService = WifiNetworkService();
  List<WifiNetwork> _wifiNetworks = [];
  bool _isWifiScanning = false;
  String? _wifiScanError;

  Future<String?> _getToken() async {
    return ServiceLocator.instance.authService.getStoredToken();
  }

  Future<void> _scanWifiNetworks() async {
    if (!mounted) return;
    setState(() {
      _isWifiScanning = true;
      _wifiScanError = null;
    });
    try {
      final networks = await _wifiNetworkService.scanNetworks();
      if (!mounted) return;
      setState(() {
        _wifiNetworks = networks;
        if (_wifiSsidController.text.isNotEmpty &&
            !networks.any((network) => network.ssid == _wifiSsidController.text)) {
          _wifiSsidController.clear();
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _wifiScanError = e.toString().replaceFirst('Bad state: ', ''));
    } finally {
      if (mounted) setState(() => _isWifiScanning = false);
    }
  }

  Future<void> _registerDevice() async {
    final serial = _serialController.text.trim();
    final mac = _macController.text.trim();
    final firmware = _firmwareController.text.trim();
    final location = _locationController.text.trim();
    final description = _descriptionController.text.trim();

    if (serial.isEmpty || mac.isEmpty) {
      AppDialogs.showErrorSnackBar(context, 'Serial number and MAC address are required.');
      return;
    }

    final token = await _getToken();
    debugPrint('RegisterDevice: stored token -> $token');
    if (token == null || token.isEmpty) {
      AppDialogs.showErrorSnackBar(context, 'Please login first to register a device.');
      return;
    }

    setState(() {
      _isRegistering = true;
      _message = null;
    }); 

    try {
      final response = await ServiceLocator.instance.deviceService.registerDevice(
        serialNumber: serial,
        macAddress: mac,
        firmwareVersion: firmware.isEmpty ? null : firmware,
        location: location.isEmpty ? null : location,
        description: description.isEmpty ? null : description,
        token: token,
      );
      final deviceToken = response['deviceToken']?.toString();
      final deviceId = response['device']?['id']?.toString();
      _deviceId = deviceId;
      _deviceToken = deviceToken;
      setState(() {
        _message = 'Device registered successfully.';
      });
      AppDialogs.showSuccessSnackBar(context, 'ESP32 registered successfully');
      await _scanWifiNetworks();
      if (deviceToken != null && deviceToken.isNotEmpty) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppColors.cardDark,
            title: Text('Device Token', style: AppTextStyles.headingMedium),
            content: SelectableText(deviceToken, style: AppTextStyles.bodyMedium),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
            ],
          ),
        );
      }
      _serialController.clear();
      _macController.clear();
      _firmwareController.clear();
      _locationController.clear();
      _descriptionController.clear();
    } catch (e) {
      AppDialogs.showErrorSnackBar(context, e.toString());
      setState(() {
        _message = e.toString();
      });
    } finally {
      setState(() {
        _isRegistering = false;
      });
    }
  }

  Future<void> _provisionToDevice() async {
    if (_deviceToken == null || _deviceId == null) {
      AppDialogs.showErrorSnackBar(context, 'Register device first to get device token.');
      return;
    }

    final ssid = _wifiSsidController.text.trim();
    final password = _wifiPasswordController.text.trim();

    if (ssid.isEmpty || password.isEmpty) {
      AppDialogs.showErrorSnackBar(context, 'Wi‑Fi SSID and password are required to provision.');
      return;
    }

    setState(() {
      _isProvisioning = true;
      _message = 'Checking connection to ESP32...';
    });

    try {
      // Step 1: Test connection to ESP32
      final testUri = Uri.parse('http://192.168.4.1/');
      http.Response? testResp;
      
      try {
        testResp = await http.get(testUri).timeout(const Duration(seconds: 5));
      } catch (e) {
        testResp = null;
      }
      
      if (testResp == null) {
        setState(() {
          _message = '❌ ESP32 not responding at 192.168.4.1\n\n'
              '✓ Make sure:\n'
              '1. ESP32 is ON and in SoftAP mode\n'
              '2. Phone is connected to ESP32 WiFi\n'
              '3. Try: Settings > WiFi > find SC_ESP32_* and connect';
        });
        AppDialogs.showErrorSnackBar(context, 'Cannot reach ESP32. Check connection steps above.');
        return;
      }

      // Step 2: Send provisioning data
      setState(() => _message = 'Sending WiFi credentials to ESP32...');
      
      final uri = Uri.parse('http://192.168.4.1/provision');
      
      // Parse backend URL to extract host:port only
      String backendUrl = AppConstants.apiBaseUrl.replaceFirst('/api/v1', '');
      // Remove http:// or https:// if present
      backendUrl = backendUrl.replaceFirst(RegExp(r'https?://'), '');
      
      final body = jsonEncode({
        'deviceId': _deviceId,
        'deviceToken': _deviceToken,
        'ssid': ssid,
        'password': password,
        'backendUrl': backendUrl,  // Now just "host:port"
      });

      final resp = await http.post(
        uri,
        headers: {'Content-Type': 'application/json','Accept': 'application/json',},
        body: body,
      ).timeout(const Duration(seconds: 60));

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        AppDialogs.showSuccessSnackBar(context, 'Provisioning data sent to ESP32.');
        setState(() {
          _message = '✅ Success! Device will connect to home WiFi now.\n'
              'Check backend in 30-60 seconds for device online status.';
        });
      } else {
        AppDialogs.showErrorSnackBar(context, 'Provision failed: ${resp.statusCode}');
        setState(() {
          _message = '❌ ESP32 rejected request (Status: ${resp.statusCode})\n'
              'Response: ${resp.body}';
        });
      }
    } on TimeoutException catch (_) {
      AppDialogs.showErrorSnackBar(context, 'ESP32 took too long to respond');
      setState(() {
        _message = '⏱️ Timeout: ESP32 not responding\n\n'
            '✓ Troubleshooting:\n'
            '1. Restart ESP32\n'
            '2. Check WiFi signal strength\n'
            '3. Verify provisioning mode is active\n'
            '4. Try again in 30 seconds';
      });
    } on SocketException catch (e) {
      AppDialogs.showErrorSnackBar(context, 'Network error: ${e.message}');
      setState(() {
        _message = '🌐 Network unreachable: ${e.message}\n\n'
            '✓ Check:\n'
            '1. Phone WiFi is ON\n'
            '2. Connected to ESP32 SoftAP\n'
            '3. Not on VPN/proxy';
      });
    } catch (e) {
      AppDialogs.showErrorSnackBar(context, 'Provisioning error: ${e.toString()}');
      setState(() {
        _message = '❌ Error: ${e.toString()}\n\n'
            'Check logs and try again.';
      });
    } finally {
      setState(() {
        _isProvisioning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 0,
        title: Text('Register ESP32', style: AppTextStyles.headingLarge.copyWith(color: cs.onSurface)),
      ),
      backgroundColor: cs.surface,
      body: Padding(
        padding: EdgeInsets.only(
          left: AppConstants.paddingMD,
          right: AppConstants.paddingMD,
          top: AppConstants.paddingMD,
          bottom: MediaQuery.viewInsetsOf(context).bottom + AppConstants.paddingMD,
        ),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            _buildTextField(_serialController, 'Serial Number', 'ESP32-SN-00124'),
            const SizedBox(height: AppConstants.paddingSM),
            _buildTextField(_macController, 'MAC Address', 'A4:CF:12:7E:2A:3B'),
            const SizedBox(height: AppConstants.paddingSM),
            _buildTextField(_firmwareController, 'Firmware Version', '2.1.4'),
            const SizedBox(height: AppConstants.paddingSM),
            _buildTextField(_locationController, 'Location (optional)', 'Rooftop North'),
            const SizedBox(height: AppConstants.paddingSM),
            _buildTextField(_descriptionController, 'Description (optional)', 'Main inverter ESP32'),
            const SizedBox(height: AppConstants.paddingMD),
            ElevatedButton(
              onPressed: _isRegistering ? null : _registerDevice,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _isRegistering
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Register Device'),
            ),
            const SizedBox(height: AppConstants.paddingSM),
            if (_deviceToken != null) ...[
              const SizedBox(height: AppConstants.paddingMD),
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingMD),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Provision ESP32 (SoftAP)', style: AppTextStyles.headingSmall),
                    const SizedBox(height: AppConstants.paddingSM),
                    Text('1) Put your ESP32 into provisioning mode (press the button).\n2) Connect your phone to the ESP32 Wi‑Fi AP (SSID: SC_ESP32_<serial>).\n3) Enter your home Wi‑Fi credentials below and tap "Send to Device".',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: AppConstants.paddingSM),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _wifiSsidController.text.isEmpty ? null : _wifiSsidController.text,
                            decoration: const InputDecoration(labelText: 'Home Wi-Fi SSID'),
                            items: _wifiNetworks
                                .map((network) => DropdownMenuItem<String>(
                                      value: network.ssid,
                                      child: Text('${network.ssid} (${network.signal}%)'),
                                    ))
                                .toList(),
                            onChanged: (ssid) {
                              if (ssid != null) _wifiSsidController.text = ssid;
                            },
                            hint: const Text('Select detected network'),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Scan Wi-Fi networks',
                          onPressed: _isWifiScanning ? null : _scanWifiNetworks,
                          icon: _isWifiScanning
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.refresh_rounded),
                        ),
                      ],
                    ),
                    if (_wifiScanError != null)
                      Text(_wifiScanError!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.error)),
                    if (!_isWifiScanning && _wifiScanError == null && _wifiNetworks.isEmpty)
                      Text('No networks detected. Turn on Wi-Fi and scan again.', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: AppConstants.paddingSM),
                    TextField(controller: _wifiPasswordController, decoration: InputDecoration(labelText: 'Home Wi‑Fi Password', filled: true, fillColor: AppColors.surfaceDark), obscureText: true),
                    const SizedBox(height: AppConstants.paddingSM),
                    ElevatedButton(
                      onPressed: _isProvisioning ? null : _provisionToDevice,
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      child: _isProvisioning ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Send to Device'),
                    ),
                  ],
                ),
              ),
            ],
            if (_message != null) ...[
              const SizedBox(height: AppConstants.paddingSM),
              Text(_message!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
            ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint) {
    return TextField(
      controller: controller,
      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: AppColors.surfaceDark,
        labelStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.divider)),
      ),
    );
  }

  @override
  void dispose() {
    _serialController.dispose();
    _macController.dispose();
    _firmwareController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _wifiSsidController.dispose();
    _wifiPasswordController.dispose();
    super.dispose();
  }
}
