import 'package:flutter/material.dart';
import '../../models/inverter_data.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class InverterSetupScreen extends StatefulWidget {
  const InverterSetupScreen({super.key});

  @override
  State<InverterSetupScreen> createState() => _InverterSetupScreenState();
}

class _InverterSetupScreenState extends State<InverterSetupScreen> {
  final TextEditingController _serialController = TextEditingController();
  bool _isValid = false;
  InverterData? _setupData;

  @override
  void initState() {
    super.initState();
    _serialController.addListener(_validateSerial);
  }

  void _validateSerial() {
    setState(() {
      _isValid = _serialController.text.length >= 8;
    });
  }

  void _handleSubmit() {
    if (!_isValid) return;

    // Show validation dialog
    _showValidationDialog();
  }

  void _showValidationDialog() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                color: AppColors.textPrimary,
              ),
              const SizedBox(height: 10),
              Text(
                _serialController.text,
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Serial No is Invalid',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Please verify the serial number and try\nagain.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Setup Inverter', style: AppTextStyles.headingLarge),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/inverter_placeholder.png',
                      width: 150,
                      height: 150,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.router_rounded,
                        size: 100,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundDark,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Provide inverter serial number',
                            style: AppTextStyles.headingMedium,
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceDark,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _serialController,
                                    style: AppTextStyles.bodyMedium,
                                    decoration: InputDecoration(
                                      hintText: '9AL1021Z100407',
                                      hintStyle: AppTextStyles.bodyMedium
                                          .copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                          'QR code scanner would open here',
                                        ),
                                        backgroundColor: AppColors.primary,
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Icon(
                                      Icons.qr_code_2_rounded,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      'Click here to scan QR Code',
                                    ),
                                    backgroundColor: AppColors.warning,
                                  ),
                                );
                              },
                              child: Text(
                                'Click here to scan QR Code',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.warning,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isValid ? _handleSubmit : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                disabledBackgroundColor:
                                    AppColors.primary.withValues(alpha: 0.5),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Submit',
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _serialController.dispose();
    super.dispose();
  }
}
