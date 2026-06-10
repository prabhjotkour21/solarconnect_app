import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/app_constants.dart';

class AppDialogs {
  // Logout confirmation dialog
  static Future<bool?> showLogoutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: Text(
          'Sign Out?',
          style: AppTextStyles.headingMedium,
        ),
        content: Text(
          'Are you sure you want to sign out of SolarConnect? You can sign back in anytime.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFEF5350),
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  // Rate us dialog
  static Future<void> showRateDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: Text(
          'Rate SolarConnect',
          style: AppTextStyles.headingMedium,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'How would you rate your experience?',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppConstants.paddingLG),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                5,
                (index) => GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Thank you for rating us ${index + 1} stars!',
                        ),
                      ),
                    );
                  },
                  child: Icon(
                    Icons.star,
                    color: AppColors.primaryOrange,
                    size: 40,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Share app dialog
  static Future<void> showShareDialog(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppConstants.paddingLG),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Share SolarConnect',
              style: AppTextStyles.headingMedium,
            ),
            const SizedBox(height: AppConstants.paddingLG),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ShareOption(
                  icon: Icons.mail,
                  label: 'Email',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Opening email...'),
                      ),
                    );
                  },
                ),
                _ShareOption(
                  icon: Icons.sms,
                  label: 'Message',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Opening messages...'),
                      ),
                    );
                  },
                ),
                _ShareOption(
                  icon: Icons.share,
                  label: 'Share',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sharing SolarConnect...'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Success feedback
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.successGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Error feedback
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.errorRed,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Generic confirmation dialog
  static Future<bool?> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmText,
    required String cancelText,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: Text(title, style: AppTextStyles.headingMedium),
        content: Text(message, style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
}

class _ShareOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ShareOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(AppConstants.radiusLG),
            ),
            child: Icon(
              icon,
              color: AppColors.primaryOrange,
              size: 28,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }
}
