import 'package:flutter/material.dart';
import '../../services/service_locator.dart';
import '../../services/wifi_network_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/app_dialogs.dart';

class WifiConfigScreen extends StatefulWidget {
  const WifiConfigScreen({super.key});

  @override
  State<WifiConfigScreen> createState() => _WifiConfigScreenState();
}

class _WifiConfigScreenState extends State<WifiConfigScreen> {
  String? _selectedNetwork;
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();
  final _passwordFieldKey = GlobalKey();
  bool _showPassword = false;
  bool _isProcessing = false;
  String? _statusMessage;
  String? _inverterId;
  String? _errorMessage;
  final _wifiNetworkService = WifiNetworkService();
  List<WifiNetwork> _networks = [];
  bool _isScanning = false;
  String? _scanError;

  @override
  void initState() {
    super.initState();
    _loadFirstInverter();
    _scanNetworks();
  }

  Future<void> _scanNetworks() async {
    if (!mounted) return;
    setState(() {
      _isScanning = true;
      _scanError = null;
    });
    try {
      final networks = await _wifiNetworkService.scanNetworks();
      if (!mounted) return;
      setState(() {
        _networks = networks;
        if (_selectedNetwork != null && !networks.any((network) => network.ssid == _selectedNetwork)) {
          _selectedNetwork = null;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _scanError = e.toString().replaceFirst('Bad state: ', ''));
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  Future<void> _loadFirstInverter() async {
    final token = await ServiceLocator.instance.authService.getStoredToken();
    if (token == null || token.isEmpty) {
      setState(() {
        _errorMessage = 'Authentication required. Please login again.';
      });
      return;
    }

    try {
      final response = await ServiceLocator.instance.inverterService.getInverters(token);
      final raw = response['data'] ?? response;
      if (raw is List && raw.isNotEmpty) {
        final first = raw.first;
        if (first is Map<String, dynamic>) {
          setState(() {
            _inverterId = first['_id']?.toString() ?? first['id']?.toString();
            _errorMessage = null;
          });
        } else if (first is Map) {
          setState(() {
            _inverterId = first['_id']?.toString() ?? first['id']?.toString();
            _errorMessage = null;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'No paired inverters found. Please pair an inverter first.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  void _selectNetwork(String ssid) {
    setState(() => _selectedNetwork = ssid);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final fieldContext = _passwordFieldKey.currentContext;
      if (fieldContext != null) {
        Scrollable.ensureVisible(
          fieldContext,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
          alignment: 0.2,
        );
      }
      _passwordFocusNode.requestFocus();
    });
  }

  Future<void> _configureWifi() async {
    if (_selectedNetwork == null) {
      AppDialogs.showErrorSnackBar(context, 'Please select a Wi-Fi network first.');
      return;
    }

    final password = _passwordController.text.trim();
    if (password.isEmpty || password.length < 8) {
      AppDialogs.showErrorSnackBar(context, 'Please enter a valid Wi-Fi password (min 8 characters).');
      return;
    }

    if (_inverterId == null || _inverterId!.isEmpty) {
      AppDialogs.showErrorSnackBar(context, 'No inverter selected. Please pair an inverter first.');
      return;
    }

    final token = await ServiceLocator.instance.authService.getStoredToken();
    if (token == null || token.isEmpty) {
      AppDialogs.showErrorSnackBar(context, 'Authentication required. Please login again.');
      return;
    }

    setState(() {
      _isProcessing = true;
      _statusMessage = null;
      _errorMessage = null;
    });

    try {
      await ServiceLocator.instance.wifiConfigService.configureWifi(
        _inverterId!,
        token,
        ssid: _selectedNetwork!,
        password: password,
        timeoutSeconds: 60,
        retry: true,
      );

      setState(() {
        _statusMessage = 'Wi-Fi credentials sent successfully.';
      });

      AppDialogs.showSuccessSnackBar(context, 'Wi-Fi configuration sent to inverter.');
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      AppDialogs.showErrorSnackBar(context, e.toString());
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
        title: Text('Wi-Fi Configuration', style: AppTextStyles.headingLarge),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline_rounded,
                          color: AppColors.primary, size: 18),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Make sure your inverter is in pairing mode',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Estimated time: 2-3 minutes',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _inverterId == null ? 'Waiting for inverter details...' : 'Using inverter: $_inverterId',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (_errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _errorMessage!,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
                ),
              ),
            if (_statusMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _statusMessage!,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.success),
                ),
              ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Select Network', style: AppTextStyles.headingMedium),
                IconButton(
                  tooltip: 'Scan again',
                  onPressed: _isScanning ? null : _scanNetworks,
                  icon: _isScanning
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (_scanError != null)
              Text(_scanError!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.error)),
            if (!_isScanning && _scanError == null && _networks.isEmpty)
              Text('No Wi-Fi networks found. Make sure Wi-Fi is on and scan again.', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),

            ..._networks.map((network) {
              final isSelected = _selectedNetwork == network.ssid;
              return GestureDetector(
                onTap: () {
                  _selectNetwork(network.ssid);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.2)
                        : AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.surfaceDark,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? Center(
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  network.ssid,
                                  style: AppTextStyles.labelLarge.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                if (network.isSecured)
                                  const SizedBox(width: 8),
                                if (network.isSecured)
                                  Icon(Icons.lock_outline,
                                      size: 14, color: AppColors.textSecondary),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Signal: ${network.signal}%',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.signal_cellular_alt_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),

            const SizedBox(height: 16),

            if (_selectedNetwork != null) ...[
              Text(
                'Enter Password',
                style: AppTextStyles.headingMedium,
              ),
              const SizedBox(height: 8),

              TextField(
                key: _passwordFieldKey,
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                obscureText: !_showPassword,
                style: AppTextStyles.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Wi-Fi Password',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      setState(() => _showPassword = !_showPassword);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _configureWifi,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    _isProcessing ? 'Connecting...' : 'Connect',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }
}
