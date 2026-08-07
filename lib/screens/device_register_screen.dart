import 'package:flutter/material.dart';
import '../services/service_locator.dart';
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

  Future<String?> _getToken() async {
    return ServiceLocator.instance.authService.getStoredToken();
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
      setState(() {
        _message = 'Device registered successfully.';
      });
      AppDialogs.showSuccessSnackBar(context, 'ESP32 registered successfully');
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
        padding: const EdgeInsets.all(AppConstants.paddingMD),
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
            if (_message != null) ...[
              const SizedBox(height: AppConstants.paddingSM),
              Text(_message!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
            ],
          ],
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
    super.dispose();
  }
}
