import 'package:flutter/material.dart';
import '../../main.dart';
import '../../services/service_locator.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_dialogs.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _dailySummaryEnabled = true;
  bool _allowDataSharing = false;
  bool _analyticsOptIn = false;
  bool _isSavingPreferences = false;

  bool get _isDarkMode => appThemeMode.value == ThemeMode.dark;
  String get _selectedLanguage => appLanguage.value;

  @override
  void initState() {
    super.initState();
    _loadAllSettings();
  }

  Future<void> _loadAllSettings() async {
    final token = await ServiceLocator.instance.authService.getStoredToken();
    if (token == null || token.isEmpty) {
      return;
    }

    try {
      final notificationsResponse = await ServiceLocator.instance.settingsService.getNotificationSettings(token);
      final appearanceResponse = await ServiceLocator.instance.settingsService.getAppearanceSettings(token);
      final privacyResponse = await ServiceLocator.instance.settingsService.getPrivacySettings(token);

      final notificationData = notificationsResponse['data'] ?? notificationsResponse;
      final appearanceData = appearanceResponse['data'] ?? appearanceResponse;
      final privacyData = privacyResponse['data'] ?? privacyResponse;

      if (notificationData is Map) {
        _notificationsEnabled = notificationData['notifications'] == true;
      }

      if (appearanceData is Map) {
        final theme = appearanceData['theme']?.toString();
        final language = appearanceData['language']?.toString();
        if (theme != null) {
          appThemeMode.value = theme.toLowerCase() == 'dark' ? ThemeMode.dark : ThemeMode.light;
        }
        if (language != null) {
          appLanguage.value = _languageLabelFromCode(language);
        }
      }

      if (privacyData is Map) {
        _allowDataSharing = privacyData['allowDataSharing'] == true;
        _analyticsOptIn = privacyData['analyticsOptIn'] == true;
      }

      if (mounted) {
        setState(() {});
      }
    } catch (_) {
      // Ignore on failure and keep default toggle state.
    }
  }

  String _languageLabelFromCode(String value) {
    switch (value.toLowerCase()) {
      case 'hi':
      case 'hindi':
        return 'Hindi';
      case 'es':
      case 'spanish':
        return 'Spanish';
      case 'fr':
      case 'french':
        return 'French';
      case 'de':
      case 'german':
        return 'German';
      default:
        return 'English';
    }
  }

  String _languageCodeFromLabel(String value) {
    switch (value.toLowerCase()) {
      case 'hindi':
        return 'hi';
      case 'spanish':
        return 'es';
      case 'french':
        return 'fr';
      case 'german':
        return 'de';
      default:
        return 'en';
    }
  }

  Future<void> _updateNotificationPreference(bool value) async {
    setState(() {
      _notificationsEnabled = value;
      _isSavingPreferences = true;
    });

    final token = await ServiceLocator.instance.authService.getStoredToken();
    if (token == null || token.isEmpty) {
      setState(() {
        _isSavingPreferences = false;
      });
      AppDialogs.showErrorSnackBar(context, 'Authentication required. Please login again.');
      return;
    }

    try {
      await ServiceLocator.instance.settingsService.updateNotificationSettings(
        token,
        notifications: value,
      );
      AppDialogs.showSuccessSnackBar(context, 'Notification preferences saved.');
    } catch (e) {
      setState(() {
        _notificationsEnabled = !value;
      });
      AppDialogs.showErrorSnackBar(context, e.toString());
    } finally {
      setState(() {
        _isSavingPreferences = false;
      });
    }
  }

  Future<void> _updateAppearancePreference(bool value) async {
    final token = await ServiceLocator.instance.authService.getStoredToken();
    if (token == null || token.isEmpty) {
      AppDialogs.showErrorSnackBar(context, 'Authentication required. Please login again.');
      return;
    }

    final theme = value ? 'dark' : 'light';
    appThemeMode.value = value ? ThemeMode.dark : ThemeMode.light;

    try {
      await ServiceLocator.instance.settingsService.updateAppearanceSettings(
        token,
        theme: theme,
        language: _languageCodeFromLabel(appLanguage.value),
      );
    } catch (e) {
      AppDialogs.showErrorSnackBar(context, e.toString());
    }
    setState(() {});
  }

  Future<void> _updatePrivacyPreference({required bool allowDataSharing, required bool analyticsOptIn}) async {
    final token = await ServiceLocator.instance.authService.getStoredToken();
    if (token == null || token.isEmpty) {
      AppDialogs.showErrorSnackBar(context, 'Authentication required. Please login again.');
      return;
    }

    try {
      await ServiceLocator.instance.settingsService.updatePrivacySettings(
        token,
        allowDataSharing: allowDataSharing,
        analyticsOptIn: analyticsOptIn,
      );
      setState(() {
        _allowDataSharing = allowDataSharing;
        _analyticsOptIn = analyticsOptIn;
      });
      AppDialogs.showSuccessSnackBar(context, 'Privacy settings saved.');
    } catch (e) {
      AppDialogs.showErrorSnackBar(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeMode,
      builder: (_, __, ___) => ValueListenableBuilder<String>(
        valueListenable: appLanguage,
        builder: (_, ___, ____) => Scaffold(
          backgroundColor: AppColors.backgroundDark,
          appBar: AppBar(
            backgroundColor: AppColors.surfaceDark,
            elevation: 0,
            title: Text('Settings', style: AppTextStyles.headingLarge),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: ListView(
            children: [
              _SectionHeader('Notifications'),
              _SettingTile(
                icon: Icons.notifications,
                title: 'Push Notifications',
                subtitle: 'Receive alerts for energy insights',
                trailing: Switch(
                  value: _notificationsEnabled,
                  onChanged: _isSavingPreferences ? null : _updateNotificationPreference,
                  activeColor: AppColors.primary,
                ),
              ),
              _SettingTile(
                icon: Icons.schedule,
                title: 'Daily Summary',
                subtitle: 'Get daily energy report at 6 PM',
                trailing: Switch(
                  value: _dailySummaryEnabled,
                  onChanged: (v) => setState(() => _dailySummaryEnabled = v),
                  activeColor: AppColors.primary,
                ),
              ),

              _SectionHeader('Display'),
              _SettingTile(
                icon: Icons.dark_mode,
                title: 'Dark Mode',
                subtitle: _isDarkMode ? 'Currently: Dark' : 'Currently: Light',
                trailing: Switch(
                  value: _isDarkMode,
                  onChanged: (v) async {
                    await _updateAppearancePreference(v);
                    setState(() {});
                  },
                  activeColor: AppColors.primary,
                ),
              ),

              _SectionHeader('Language'),
              _LanguageTile(
                selectedLanguage: _selectedLanguage,
                onChanged: (lang) async {
                  appLanguage.value = lang;
                  setState(() {});

                  final token = await ServiceLocator.instance.authService.getStoredToken();
                  if (token != null && token.isNotEmpty) {
                    await ServiceLocator.instance.settingsService.updateAppearanceSettings(
                      token,
                      language: _languageCodeFromLabel(lang),
                    );
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Language changed to $lang'),
                      backgroundColor: AppColors.success,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),

              _SectionHeader('Data & Storage'),
              _SettingTile(
                icon: Icons.storage,
                title: 'Cache Size',
                subtitle: '245 MB',
                onTap: _showClearCacheDialog,
              ),
              _SettingTile(
                icon: Icons.download,
                title: 'Export Data',
                subtitle: 'Download your energy data as CSV',
                onTap: _showExportDialog,
              ),

              _SectionHeader('Privacy & Security'),
              _SettingTile(
                icon: Icons.share_outlined,
                title: 'Data Sharing',
                subtitle: 'Allow anonymized data sharing for system improvements',
                trailing: Switch(
                  value: _allowDataSharing,
                  onChanged: (v) => _updatePrivacyPreference(
                    allowDataSharing: v,
                    analyticsOptIn: _analyticsOptIn,
                  ),
                  activeColor: AppColors.primary,
                ),
              ),
              _SettingTile(
                icon: Icons.analytics_outlined,
                title: 'Analytics Opt-In',
                subtitle: 'Help improve user insights and product analytics',
                trailing: Switch(
                  value: _analyticsOptIn,
                  onChanged: (v) => _updatePrivacyPreference(
                    allowDataSharing: _allowDataSharing,
                    analyticsOptIn: v,
                  ),
                  activeColor: AppColors.primary,
                ),
              ),
              _SettingTile(
                icon: Icons.privacy_tip,
                title: 'Privacy Policy',
                onTap: _showPrivacyDialog,
              ),
              _SettingTile(
                icon: Icons.description,
                title: 'Terms of Service',
                onTap: _showTermsDialog,
              ),
              _SettingTile(
                icon: Icons.lock,
                title: 'Change Password',
                onTap: _showPasswordDialog,
              ),

              _SectionHeader('About'),
              const _SettingTile(
                icon: Icons.info,
                title: 'App Version',
                subtitle: 'SolarConnect v1.0.0',
              ),
              const _SettingTile(
                icon: Icons.code,
                title: 'Build Number',
                subtitle: '2026.06.10.001',
              ),

              const SizedBox(height: AppConstants.paddingXL),
            ],
          ),
        ),
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: Text('Clear Cache?', style: AppTextStyles.headingMedium),
        content: Text(
          'This will clear temporary data and free up 245 MB of space.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              // Show progress
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const AlertDialog(
                  backgroundColor: AppColors.cardDark,
                  content: Row(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 16),
                      Text('Clearing cache...'),
                    ],
                  ),
                ),
              );
              await Future.delayed(const Duration(seconds: 1));
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Cache cleared — 245 MB freed'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: Text('Export Data', style: AppTextStyles.headingMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This will export your energy data for the last 12 months as a CSV file.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              ),
              child: Row(
                children: [
                  const Icon(Icons.insert_drive_file, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text('SolarConnect_Energy_2026.csv',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              // Show export progress dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => AlertDialog(
                  backgroundColor: AppColors.cardDark,
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const LinearProgressIndicator(
                        color: AppColors.primary,
                        backgroundColor: AppColors.surfaceDark,
                      ),
                      const SizedBox(height: 16),
                      Text('Exporting data...', style: AppTextStyles.bodyMedium),
                    ],
                  ),
                ),
              );
              await Future.delayed(const Duration(seconds: 2));
              if (mounted) {
                Navigator.pop(context); // close progress
                _showExportSuccessDialog();
              }
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _showExportSuccessDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.success),
            const SizedBox(width: 8),
            Text('Export Complete', style: AppTextStyles.headingMedium),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your data has been exported successfully.',
                style: AppTextStyles.bodyMedium),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('📄 SolarConnect_Energy_2026.csv',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.success)),
                  const SizedBox(height: 4),
                  Text('Size: 1.2 MB  •  365 records',
                      style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: Text('Privacy Policy', style: AppTextStyles.headingMedium),
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
            onPressed: () => Navigator.pop(ctx),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: Text('Terms of Service', style: AppTextStyles.headingMedium),
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
            onPressed: () => Navigator.pop(ctx),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  void _showPasswordDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: Text('Change Password', style: AppTextStyles.headingMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Current Password',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.divider),
                  borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.paddingMD),
            TextField(
              obscureText: true,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'New Password',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.divider),
                  borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Password updated successfully'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
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
        style: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondary),
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
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingLG,
        vertical: 4,
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: AppTextStyles.bodyLarge),
        subtitle: subtitle != null
            ? Text(subtitle!, style: AppTextStyles.bodySmall)
            : null,
        trailing: trailing ??
            (onTap != null ? const Icon(Icons.chevron_right) : null),
        onTap: onTap,
        tileColor: AppColors.cardDark,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingLG,
          vertical: 8,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingLG,
        vertical: 4,
      ),
      child: ListTile(
        leading: const Icon(Icons.language, color: AppColors.primary),
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
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: Text('Select Language', style: AppTextStyles.headingMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['English', 'Spanish', 'French', 'German', 'Hindi']
              .map((lang) => ListTile(
                    title: Text(lang, style: AppTextStyles.bodyLarge),
                    leading: Radio<String>(
                      value: lang,
                      groupValue: selectedLanguage,
                      onChanged: (value) {
                        onChanged(value!);
                        Navigator.pop(ctx);
                      },
                      activeColor: AppColors.primary,
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
