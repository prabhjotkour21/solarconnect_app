import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/app_constants.dart';
import '../../services/service_locator.dart';
import '../../utils/app_dialogs.dart';

class InverterSetupScreen extends StatefulWidget {
  const InverterSetupScreen({super.key});

  @override
  State<InverterSetupScreen> createState() => _InverterSetupScreenState();
}

class _InverterSetupScreenState extends State<InverterSetupScreen> {
  final TextEditingController _serialController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _firmwareController = TextEditingController();
  bool _isPairing = false;
  bool _isLoadingList = true;
  String? _message;
  List<Map<String, dynamic>> _inventory = [];

  @override
  void initState() {
    super.initState();
    _loadInverters();
  }

  Future<String?> _getToken() async {
    return ServiceLocator.instance.authService.getStoredToken();
  }

  Future<void> _loadInverters() async {
    setState(() {
      _isLoadingList = true;
      _message = null;
    });

    final token = await _getToken();
    if (token == null || token.isEmpty) {
      setState(() {
        _message = 'Authentication token not found. Please login again.';
        _isLoadingList = false;
      });
      return;
    }

    try {
      final response = await ServiceLocator.instance.inverterService.getInverters(token);
      final raw = response['data'] ?? response;
      if (raw is List) {
        setState(() {
          _inventory = raw.map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item as Map<String, dynamic>)).toList();
          _message = null;
        });
      } else if (raw is Map<String, dynamic>) {
        setState(() {
          _inventory = [raw];
          _message = null;
        });
      } else {
        setState(() {
          _inventory = [];
          _message = 'No inverters found.';
        });
      }
    } catch (e) {
      setState(() {
        _inventory = [];
        _message = e.toString();
      });
    } finally {
      setState(() {
        _isLoadingList = false;
      });
    }
  }

  Future<void> _pairInverter() async {
    final serial = _serialController.text.trim();
    final model = _modelController.text.trim();
    final brand = _brandController.text.trim();
    final location = _locationController.text.trim();
    final firmware = _firmwareController.text.trim();

    if (serial.isEmpty || model.isEmpty || brand.isEmpty) {
      AppDialogs.showErrorSnackBar(context, 'Serial, model and brand are required.');
      return;
    }

    final token = await _getToken();
    if (token == null || token.isEmpty) {
      AppDialogs.showErrorSnackBar(context, 'Please login again before pairing an inverter.');
      return;
    }

    setState(() {
      _isPairing = true;
      _message = null;
    });

    try {
      final response = await ServiceLocator.instance.inverterService.pairInverter(
        serialNumber: serial,
        model: model,
        brand: brand,
        location: location.isEmpty ? null : location,
        firmwareVersion: firmware.isEmpty ? null : firmware,
        token: token,
      );
      setState(() {
        _message = 'Inverter paired successfully.';
      });
      _serialController.clear();
      _modelController.clear();
      _brandController.clear();
      _locationController.clear();
      _firmwareController.clear();
      await _loadInverters();
      AppDialogs.showSuccessSnackBar(context, 'Inverter paired successfully');
    } catch (e) {
      AppDialogs.showErrorSnackBar(context, e.toString());
      setState(() {
        _message = e.toString();
      });
    } finally {
      setState(() {
        _isPairing = false;
      });
    }
  }

  Future<void> _showInverterDetails(Map<String, dynamic> inverter) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      AppDialogs.showErrorSnackBar(context, 'Please login again.');
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final id = inverter['_id']?.toString() ?? inverter['id']?.toString() ?? 'unknown';
        final status = inverter['status']?.toString() ?? 'Unknown';
        final pairedDate = inverter['pairedDate']?.toString() ?? 'N/A';
        final model = inverter['model']?.toString() ?? 'N/A';
        final brand = inverter['brand']?.toString() ?? 'N/A';
        final serial = inverter['serialNumber']?.toString() ?? 'N/A';
        final location = inverter['location']?.toString() ?? 'N/A';

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Inverter Details', style: AppTextStyles.headingMedium),
              const SizedBox(height: 12),
              _detailRow('Serial', serial),
              _detailRow('Model', model),
              _detailRow('Brand', brand),
              _detailRow('Location', location),
              _detailRow('Status', status),
              _detailRow('Paired', pairedDate),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _fetchInverterStatus(id);
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: const Text('View Status'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showUpdateDialog(id, inverter);
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                child: const Text('Update Inverter'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _confirmUnpair(id);
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
                child: const Text('Unpair Inverter'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _confirmDelete(id);
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                child: const Text('Delete Inverter'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showSavingsHistory(id);
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary.withValues(alpha: 0.8)),
                child: const Text('View Savings History'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text('$label:', style: AppTextStyles.bodySmall)),
          Expanded(
            flex: 2,
            child: Text(value, style: AppTextStyles.bodyMedium, textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchInverterStatus(String id) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      AppDialogs.showErrorSnackBar(context, 'Please login again.');
      return;
    }

    try {
      final response = await ServiceLocator.instance.inverterService.getInverterStatus(id, token);
      final statusData = response['data'] ?? response;
      if (statusData is! Map<String, dynamic>) {
        AppDialogs.showErrorSnackBar(context, 'Failed to load inverter status.');
        return;
      }
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: AppColors.cardDark,
          title: Text('Inverter Status', style: AppTextStyles.headingMedium),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: statusData.entries
                .map((entry) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text('${entry.key}: ${entry.value}', style: AppTextStyles.bodySmall),
                    ))
                .toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      AppDialogs.showErrorSnackBar(context, e.toString());
    }
  }

  Future<void> _showUpdateDialog(String id, Map<String, dynamic> inverter) async {
    final location = TextEditingController(text: inverter['location']?.toString() ?? '');
    final firmware = TextEditingController(text: inverter['firmwareVersion']?.toString() ?? '');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: Text('Update Inverter', style: AppTextStyles.headingMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: location,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            TextField(
              controller: firmware,
              decoration: const InputDecoration(labelText: 'Firmware Version'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
        ],
      ),
    );

    if (confirmed != true) return;

    final token = await _getToken();
    if (token == null || token.isEmpty) {
      AppDialogs.showErrorSnackBar(context, 'Please login again.');
      return;
    }

    try {
      await ServiceLocator.instance.inverterService.updateInverter(
        id,
        token,
        data: {
          if (location.text.isNotEmpty) 'location': location.text.trim(),
          if (firmware.text.isNotEmpty) 'firmwareVersion': firmware.text.trim(),
        },
      );
      AppDialogs.showSuccessSnackBar(context, 'Inverter updated successfully');
      _loadInverters();
    } catch (e) {
      AppDialogs.showErrorSnackBar(context, e.toString());
    }
  }

  Future<void> _confirmUnpair(String id) async {
    final confirmed = await AppDialogs.showConfirmDialog(
      context,
      title: 'Unpair Inverter',
      message: 'Do you want to unpair this inverter? It will become inactive.',
      confirmText: 'Unpair',
      cancelText: 'Cancel',
    );
    if (confirmed != true) return;

    final token = await _getToken();
    if (token == null || token.isEmpty) {
      AppDialogs.showErrorSnackBar(context, 'Please login again.');
      return;
    }

    try {
      await ServiceLocator.instance.inverterService.unpairInverter(id, token);
      AppDialogs.showSuccessSnackBar(context, 'Inverter unpaired successfully');
      _loadInverters();
    } catch (e) {
      AppDialogs.showErrorSnackBar(context, e.toString());
    }
  }

  Future<void> _confirmDelete(String id) async {
    final confirmed = await AppDialogs.showConfirmDialog(
      context,
      title: 'Delete Inverter',
      message: 'This will remove the inverter from your account permanently.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
    );
    if (confirmed != true) return;

    final token = await _getToken();
    if (token == null || token.isEmpty) {
      AppDialogs.showErrorSnackBar(context, 'Please login again.');
      return;
    }

    try {
      await ServiceLocator.instance.inverterService.deleteInverter(id, token);
      AppDialogs.showSuccessSnackBar(context, 'Inverter deleted successfully');
      _loadInverters();
    } catch (e) {
      AppDialogs.showErrorSnackBar(context, e.toString());
    }
  }

  Future<void> _showSavingsHistory(String id) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      AppDialogs.showErrorSnackBar(context, 'Please login again.');
      return;
    }

    try {
      final response = await ServiceLocator.instance.inverterService.getSavingsHistory(id, token);
      final raw = response['data'] ?? response;
      final history = raw is List ? raw : [raw];
      if (history.isEmpty) {
        AppDialogs.showErrorSnackBar(context, 'No savings history available.');
        return;
      }

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: AppColors.cardDark,
          title: Text('Savings History', style: AppTextStyles.headingMedium),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: history.length,
              separatorBuilder: (_, __) => const Divider(color: Colors.white12),
              itemBuilder: (context, index) {
                final item = Map<String, dynamic>.from(history[index] as Map<String, dynamic>);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: item.entries
                      .map((entry) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text('${entry.key}: ${entry.value}', style: AppTextStyles.bodySmall),
                          ))
                      .toList(),
                );
              },
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ],
        ),
      );
    } catch (e) {
      AppDialogs.showErrorSnackBar(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: cs.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Inverter Manager', style: AppTextStyles.headingLarge.copyWith(color: cs.onSurface)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMD),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.paddingMD),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppConstants.radiusLG),
                border: Border.all(color: cs.outline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Pair New Inverter', style: AppTextStyles.headingSmall.copyWith(color: cs.onSurface)),
                  const SizedBox(height: AppConstants.paddingSM),
                  _buildInputField(_serialController, 'Serial Number', '9AL1021Z100407'),
                  const SizedBox(height: AppConstants.paddingSM),
                  _buildInputField(_modelController, 'Model', 'SC-5K'),
                  const SizedBox(height: AppConstants.paddingSM),
                  _buildInputField(_brandController, 'Brand', 'SolarConnect'),
                  const SizedBox(height: AppConstants.paddingSM),
                  _buildInputField(_locationController, 'Location (optional)', 'Roof top'),
                  const SizedBox(height: AppConstants.paddingSM),
                  _buildInputField(_firmwareController, 'Firmware version (optional)', '2.1.0'),
                  const SizedBox(height: AppConstants.paddingMD),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isPairing ? null : _pairInverter,
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: _isPairing
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Pair Inverter'),
                    ),
                  ),
                  if (_message != null) ...[
                    const SizedBox(height: AppConstants.paddingSM),
                    Text(_message!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppConstants.paddingMD),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppConstants.radiusLG),
                  border: Border.all(color: cs.outline),
                ),
                child: _isLoadingList
                    ? const Center(child: CircularProgressIndicator())
                    : _inventory.isEmpty
                        ? Center(child: Text('No inverters paired yet.', style: AppTextStyles.bodyMedium.copyWith(color: cs.onSurfaceVariant)))
                        : ListView.separated(
                            padding: const EdgeInsets.all(AppConstants.paddingMD),
                            itemCount: _inventory.length,
                            separatorBuilder: (_, __) => const SizedBox(height: AppConstants.paddingMD),
                            itemBuilder: (context, index) {
                              final inverter = _inventory[index];
                              final serial = inverter['serialNumber']?.toString() ?? 'Unknown';
                              final model = inverter['model']?.toString() ?? 'Unknown';
                              final status = inverter['status']?.toString() ?? 'Unknown';
                              return InkWell(
                                borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                                onTap: () => _showInverterDetails(inverter),
                                child: Container(
                                  padding: const EdgeInsets.all(AppConstants.paddingMD),
                                  decoration: BoxDecoration(
                                    color: cs.surface,
                                    borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                                    border: Border.all(color: cs.outline),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(serial, style: AppTextStyles.bodyLarge.copyWith(color: cs.onSurface)),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary.withValues(alpha: 0.12),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(status, style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary)),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(model, style: AppTextStyles.bodySmall.copyWith(color: cs.onSurfaceVariant)),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String label, String hint) {
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
    _modelController.dispose();
    _brandController.dispose();
    _locationController.dispose();
    _firmwareController.dispose();
    super.dispose();
  }
}
