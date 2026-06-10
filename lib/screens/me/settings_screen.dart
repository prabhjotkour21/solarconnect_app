import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/app_constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = true;
  String _selectedLanguage = 'English';
  bool _privacyAgreed = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
        title: Text(
          'Settings',
          style: AppTextStyles.headingLarge,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          // Notifications Section
          _SectionHeader('Notifications'),
          _SettingTile(
            icon: Icons.notifications,
            title: 'Push Notifications',
            subtitle: 'Receive alerts for energy insights',
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() => _notificationsEnabled = value);
              },
              activeColor: AppColors.primaryOrange,
            ),
          ),
          _SettingTile(
            icon: Icons.schedule,
            title: 'Daily Summary',
            subtitle: 'Get daily energy report at 6 PM',
            trailing: Switch(
              value: true,
              onChanged: (_) {},
              activeColor: AppColors.primaryOrange,
            ),
          ),

          // Display Section
          _SectionHeader('Display'),
          _SettingTile(
            icon: Icons.dark_mode,
            title: 'Dark Mode',
            subtitle: 'Currently enabled',
            trailing: Switch(
              value: _darkModeEnabled,
              onChanged: (value) {
                setState(() => _darkModeEnabled = value);
              },
              activeColor: AppColors.primaryOrange,
            ),
          ),

          // Language Section
          _SectionHeader('Language'),
          _LanguageTile(
            selectedLanguage: _selectedLanguage,
            onChanged: (language) {
              setState(() => _selectedLanguage = language);
            },
          ),

          // Data Section
          _SectionHeader('Data & Storage'),
          _SettingTile(
            icon: Icons.storage,
            title: 'Cache Size',
            subtitle: '245 MB',
            onTap: () => _showClearCacheDialog(),
          ),
          _SettingTile(
            icon: Icons.download,
            title: 'Export Data',
            subtitle: 'Download your energy data as CSV',
            onTap: () => _showExportDialog(),
          ),

          // Privacy Section
          _SectionHeader('Privacy & Security'),
          _SettingTile(
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            onTap: () => _showPrivacyDialog(),
          ),
          _SettingTile(
            icon: Icons.description,
            title: 'Terms of Service',
            onTap: () => _showTermsDialog(),
          ),
          _SettingTile(
            icon: Icons.lock,
            title: 'Change Password',
            onTap: () => _showPasswordDialog(),
          ),

          // About Section
          _SectionHeader('About'),
          _SettingTile(
            icon: Icons.info,
            title: 'App Version',
            subtitle: 'SolarConnect v1.0.0',
          ),
          _SettingTile(
            icon: Icons.code,
            title: 'Build Number',
            subtitle: '2026.06.10.001',
          ),

          const SizedBox(height: AppConstants.paddingXL),
        ],
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: Text(
          'Clear Cache?',
          style: AppTextStyles.headingMedium,
        ),
        content: Text(
          'This will clear temporary data and free up 245 MB of space.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared successfully')),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: Text(
          'Export Data',
          style: AppTextStyles.headingMedium,
        ),
        content: Text(
          'Export your energy data for the last 12 months?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data exported to Downloads')),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
            ),
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: Text(
          'Privacy Policy',
          style: AppTextStyles.headingMedium,
        ),
        content: SingleChildScrollView(
          child: Text(
            'SolarConnect is committed to protecting your privacy. '
            'We collect minimal data necessary to provide our services. '
            'Your energy data is encrypted and never shared with third parties.\n\n'
            'Last updated: June 2026',
            style: AppTextStyles.bodyMedium,
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
            ),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: Text(
          'Terms of Service',
          style: AppTextStyles.headingMedium,
        ),
        content: SingleChildScrollView(
          child: Text(
            'By using SolarConnect, you agree to these terms:\n\n'
            '• You own all data you generate\n'
            '• We provide the service as-is\n'
            '• You are responsible for system maintenance\n'
            '• We reserve the right to update these terms\n\n'
            'Last updated: June 2026',
            style: AppTextStyles.bodyMedium,
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
            ),
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  void _showPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: Text(
          'Change Password',
          style: AppTextStyles.headingMedium,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              style: const TextStyle(color: AppColors.primaryText),
              decoration: InputDecoration(
                hintText: 'Current Password',
                hintStyle: const TextStyle(color: AppColors.secondaryText),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusMD),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.dividerColor),
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusMD),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.paddingMD),
            TextField(
              obscureText: true,
              style: const TextStyle(color: AppColors.primaryText),
              decoration: InputDecoration(
                hintText: 'New Password',
                hintStyle: const TextStyle(color: AppColors.secondaryText),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusMD),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.dividerColor),
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusMD),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password updated')),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.paddingLG,
        AppConstants.paddingLG,
        AppConstants.paddingLG,
        AppConstants.paddingMD,
      ),
      child: Text(
        title,
        style: AppTextStyles.labelLarge.copyWith(
          color: AppColors.secondaryText,
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryOrange),
      title: Text(title, style: AppTextStyles.bodyLarge),
      subtitle: subtitle != null
          ? Text(subtitle!, style: AppTextStyles.bodySmall)
          : null,
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
      onTap: onTap,
      tileColor: AppColors.cardDark,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingLG,
        vertical: 8,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingLG,
        vertical: 4,
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String selectedLanguage;
  final Function(String) onChanged;

  const _LanguageTile({
    required this.selectedLanguage,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.language, color: AppColors.primaryOrange),
      title: Text('Language', style: AppTextStyles.bodyLarge),
      subtitle: Text(selectedLanguage, style: AppTextStyles.bodySmall),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showLanguageDialog(context),
      tileColor: AppColors.cardDark,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingLG,
        vertical: 8,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingLG,
        vertical: 4,
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: Text(
          'Select Language',
          style: AppTextStyles.headingMedium,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['English', 'Spanish', 'French', 'German', 'Hindi']
              .map((lang) => ListTile(
                    title: Text(lang, style: AppTextStyles.bodyLarge),
                    leading: Radio(
                      value: lang,
                      groupValue: selectedLanguage,
                      onChanged: (value) {
                        onChanged(value!);
                        Navigator.pop(context);
                      },
                      activeColor: AppColors.primaryOrange,
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
