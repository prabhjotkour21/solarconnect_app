import 'package:flutter/material.dart';
import '../../main.dart';
import '../../models/notification_preference.dart';
import '../../services/service_locator.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_dialogs.dart';
import 'settings_screen.dart';
import 'help_screen.dart';
import '../trends_screen.dart';
import '../insights_screen.dart';
import '../power_cut_screen.dart';
import '../savings_screen.dart';
import '../notifications_screen.dart';
import '../inverter_setup_screen.dart';
import '../wifi_config_screen.dart';
import '../device_register_screen.dart';

class MeScreen extends StatefulWidget {
  const MeScreen({super.key});

  @override
  State<MeScreen> createState() => _MeScreenState();
}

class _MeScreenState extends State<MeScreen> {
  Map<String, dynamic> _userProfile = {};
  Map<String, dynamic> _primaryInverter = {};
  String _inverterStatus = 'offline';
  bool _isLoadingProfile = true;
  
  // Dynamic notification preferences
  NotificationPreference? _notificationPrefs;
  bool _isLoadingNotificationPrefs = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadNotificationPreferences();
  }

  Future<void> _loadNotificationPreferences() async {
    setState(() {
      _isLoadingNotificationPrefs = true;
    });

    final token = await ServiceLocator.instance.authService.getStoredToken();
    if (token == null || token.isEmpty) {
      setState(() {
        _isLoadingNotificationPrefs = false;
        _notificationPrefs = NotificationPreference.defaultPreferences();
      });
      return;
    }

    try {
      final prefs = await ServiceLocator.instance.notificationService
          .getNotificationPreferences(token);
      if (mounted) {
        setState(() {
          _notificationPrefs = prefs;
          _isLoadingNotificationPrefs = false;
        });
      }
    } catch (e) {
      print('[ME_SCREEN] Error loading notification preferences: $e');
      if (mounted) {
        setState(() {
          _notificationPrefs = NotificationPreference.defaultPreferences();
          _isLoadingNotificationPrefs = false;
        });
      }
    }
  }

  Future<void> _loadUserProfile() async {
    final token = await ServiceLocator.instance.authService.getStoredToken();
    print(
      '[ME_SCREEN] Starting _loadUserProfile() | token: ${token != null ? token.substring(0, 20) + '...' : 'NULL'}',
    );

    if (token == null || token.isEmpty) {
      print('[ME_SCREEN] Token is null/empty, loading from storage');
      final storedUser = await ServiceLocator.instance.authService
          .getStoredUserData();
      if (mounted) {
        setState(() {
          _userProfile = storedUser ?? {};
          _isLoadingProfile = false;
        });
      }
      return;
    }

    try {
      print('[ME_SCREEN] Fetching user profile...');
      // Load user profile
      final response = await ServiceLocator.instance.authService.getMe(token);
      final profile = response['data'] is Map
          ? Map<String, dynamic>.from(response['data'])
          : response;
      print('[ME_SCREEN] User profile loaded: ${profile['email']}');

      // Load inverters
      Map<String, dynamic>? primaryInverter;
      String status = 'offline';

      try {
        final dynamic invertersResponse = await ServiceLocator
            .instance
            .inverterService
            .getInverters(token);

        // Backend returns array directly, not wrapped in 'data'
        List<dynamic> invertersList = [];
        if (invertersResponse is List) {
          // Direct array response
          print(
            '[ME_SCREEN] Response is List with ${(invertersResponse as List).length} items',
          );
          invertersList = List<dynamic>.from(invertersResponse);
        } else if (invertersResponse is Map &&
            invertersResponse['data'] is List) {
          invertersList = List<dynamic>.from(invertersResponse['data'] as List);
        }

        if (invertersList.isNotEmpty) {
          primaryInverter = Map<String, dynamic>.from(
            invertersList.first as Map<String, dynamic>,
          );

          // Get inverter status if we have an inverter ID
          final inverterId =
              primaryInverter['_id']?.toString() ??
              primaryInverter['id']?.toString();
          if (inverterId != null && inverterId.isNotEmpty) {
            try {
              final statusResponse = await ServiceLocator
                  .instance
                  .inverterService
                  .getInverterStatus(inverterId, token);
              status =
                  statusResponse['status']?.toString() ??
                  primaryInverter['status']?.toString() ??
                  'offline';
            } catch (_) {
              status = primaryInverter['status']?.toString() ?? 'offline';
            }
          }
        }
      } catch (e, st) {
        // If inverters fail to load, continue with just user profile
        print('[ME_SCREEN] Error loading inverters: $e');
        print(st);
      }

      if (mounted) {
        setState(() {
          _userProfile = profile;
          _primaryInverter = primaryInverter ?? {};
          _inverterStatus = status;
          _isLoadingProfile = false;
        });
        print(
          '[ME_SCREEN] Updated state: inverterStatus=$status, systemSize=${_systemSizeKwp}, battery=${_batteryCapacityKwh}, revenue=${_totalRevenue}',
        );
      }
    } catch (_) {
      final storedUser = await ServiceLocator.instance.authService
          .getStoredUserData();
      if (mounted) {
        setState(() {
          _userProfile = storedUser ?? {};
          _isLoadingProfile = false;
        });
      }
    }
  }

  String get _fullName {
    final first = _userProfile['firstName']?.toString().trim();
    final last = _userProfile['lastName']?.toString().trim();
    if (first != null && first.isNotEmpty && last != null && last.isNotEmpty) {
      return '$first $last';
    }
    if (first != null && first.isNotEmpty) return first;
    if (last != null && last.isNotEmpty) return last;
    final name = _userProfile['name']?.toString().trim();
    if (name != null && name.isNotEmpty) return name;
    return 'User';
  }

  String get _phoneNumber {
    final value =
        _userProfile['phoneNumber'] ??
        _userProfile['phone'] ??
        _userProfile['mobile'];
    final text = value?.toString().trim();
    return text != null && text.isNotEmpty ? text : 'No phone number';
  }

  String get _planLabel {
    final label =
        _userProfile['plan'] ??
        _userProfile['accountType'] ??
        _userProfile['subscription'];
    final text = label?.toString().trim();
    if (text == null || text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1);
  }

  double get _systemSizeKwp {
    // Try to get from inverter specifications first
    final invertSpecSize = _primaryInverter['specifications']?['panelCapacity'];
    if (invertSpecSize is num) return invertSpecSize.toDouble();

    // Fall back to user profile
    final value =
        _userProfile['systemSizeKwp'] ?? _userProfile['systemSize'] ?? 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  double get _batteryCapacityKwh {
    // Try to get from inverter specifications first
    final invertSpecBattery =
        _primaryInverter['specifications']?['batteryCapacity'];
    if (invertSpecBattery is num) return invertSpecBattery.toDouble();

    // Fall back to user profile
    final value =
        _userProfile['batteryCapacityKwh'] ?? _userProfile['battery'] ?? 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  double get _totalRevenue {
    final value =
        _userProfile['totalRevenue'] ??
        _userProfile['revenue'] ??
        _userProfile['investmentAmount'] ??
        0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  bool get _isSystemOnline {
    // connectionStatus: 'online' or 'offline' from inverter status API
    if (_inverterStatus.toLowerCase() == 'online') return true;

    // Fallback to status field if connectionStatus not available
    final status = _inverterStatus.toLowerCase();
    return status == 'active' || status == 'online' || status == 'success';
  }

  void _handleMenuTap(BuildContext context, String item) {
    switch (item) {
      case 'FAQ':
      case 'Contact Support':
      case 'User Guide':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HelpScreen()),
        );
        break;
      case 'Notifications':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NotificationsScreen()),
        );
        break;
      case 'Appearance':
      case 'Language':
      case 'Privacy':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SettingsScreen()),
        );
        break;
      case 'Trends':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TrendsScreen()),
        );
        break;
      case 'Insights':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const InsightsScreen()),
        );
        break;
      case 'Power Cut':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PowerCutScreen()),
        );
        break;
      case 'Savings':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SavingsScreen()),
        );
        break;
      case 'Setup Inverter':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const InverterSetupScreen()),
        );
        break;
      case 'Wi-Fi Configuration':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const WifiConfigScreen()),
        );
        break;
      case 'Register ESP32':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DeviceRegisterScreen()),
        );
        break;
      case 'Share App':
        AppDialogs.showShareDialog(context);
        break;
      case 'Rate Us':
        AppDialogs.showRateDialog(context);
        break;
      case 'Sign Out':
        _handleLogout(context);
        break;
    }
  }

  void _handleLogout(BuildContext context) async {
    final confirmed = await AppDialogs.showLogoutDialog(context);
    if (confirmed != true) return;

    final token = await ServiceLocator.instance.authService.getStoredToken();
    if (token != null && token.isNotEmpty) {
      try {
        await ServiceLocator.instance.authService.logout(token);
      } catch (_) {
        // Even if backend logout fails, we still clear local session.
      }
    }

    await ServiceLocator.instance.authService.clearStoredAuth();

    if (context.mounted) {
      AppDialogs.showSuccessSnackBar(context, 'Signed out successfully');
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  Future<void> _openEditProfileDialog() async {
    final firstNameController = TextEditingController(
      text: _userProfile['firstName']?.toString() ?? '',
    );
    final lastNameController = TextEditingController(
      text: _userProfile['lastName']?.toString() ?? '',
    );
    final phoneController = TextEditingController(
      text: _userProfile['phoneNumber']?.toString() ?? '',
    );

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text('Edit Profile', style: AppTextStyles.headingMedium),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: firstNameController,
                    decoration: const InputDecoration(labelText: 'First Name'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: lastNameController,
                    decoration: const InputDecoration(labelText: 'Last Name'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, {
                  'firstName': firstNameController.text.trim(),
                  'lastName': lastNameController.text.trim(),
                  'phoneNumber': phoneController.text.trim(),
                });
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result == null || !mounted) return;

    final firstName = result['firstName'] ?? '';
    final lastName = result['lastName'] ?? '';
    final phoneNumber = result['phoneNumber'] ?? '';

    if (firstName.isEmpty && lastName.isEmpty && phoneNumber.isEmpty) {
      return;
    }

    final token = await ServiceLocator.instance.authService.getStoredToken();
    if (token == null || token.isEmpty) {
      AppDialogs.showErrorSnackBar(
        context,
        'Authentication required. Please login again.',
      );
      return;
    }

    try {
      final payload = <String, dynamic>{};
      if (firstName.isNotEmpty) payload['firstName'] = firstName;
      if (lastName.isNotEmpty) payload['lastName'] = lastName;
      if (phoneNumber.isNotEmpty) payload['phoneNumber'] = phoneNumber;

      final updatedResponse = await ServiceLocator.instance.userProfileService
          .updateProfile(token, data: payload);

      final updatedProfile = updatedResponse['data'] is Map
          ? Map<String, dynamic>.from(updatedResponse['data'])
          : updatedResponse;

      setState(() {
        _userProfile = Map<String, dynamic>.from(updatedProfile);
      });

      await ServiceLocator.instance.authService.persistUserData(
        Map<String, dynamic>.from(updatedProfile),
      );

      if (mounted) {
        AppDialogs.showSuccessSnackBar(context, 'Profile updated successfully');
      }
    } catch (e) {
      if (mounted) {
        AppDialogs.showErrorSnackBar(context, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild when theme or language changes
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeMode,
      builder: (_, __, ___) => ValueListenableBuilder<String>(
        valueListenable: appLanguage,
        builder: (_, lang, ___) {
          final cs = Theme.of(context).colorScheme;
          return Scaffold(
            backgroundColor: cs.surface,
            body: SafeArea(
              top: true,
              bottom: true,
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    backgroundColor: cs.surface,
                    title: Text(
                      'My Account',
                      style: AppTextStyles.headingMedium,
                    ),
                    floating: true,
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppConstants.paddingMD,
                      0,
                      AppConstants.paddingMD,
                      AppConstants.paddingXL,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _ProfileHeader(
                          fullName: _fullName,
                          phoneNumber: _phoneNumber,
                          planLabel: _planLabel,
                          isLoading: _isLoadingProfile,
                          onEdit: _openEditProfileDialog,
                        ),
                        const SizedBox(height: AppConstants.paddingMD),
                        _SystemInfoCard(
                          systemSizeKwp: _systemSizeKwp,
                          totalRevenue: _totalRevenue,
                          batteryCapacityKwh: _batteryCapacityKwh,
                          isOnline: _isSystemOnline,
                        ),
                        const SizedBox(height: AppConstants.paddingMD),
                        const _SectionLabel('Analytics & Monitoring'),
                        _MenuGroup(
                          items: const [
                            _MenuItem(
                              Icons.trending_up_rounded,
                              'Trends',
                              'View historical data',
                            ),
                            _MenuItem(
                              Icons.insights_rounded,
                              'Insights',
                              'Performance analysis',
                            ),
                            _MenuItem(
                              Icons.power_off_rounded,
                              'Power Cut',
                              'Power outage tracking',
                            ),
                            _MenuItem(
                              Icons.savings_rounded,
                              'Savings',
                              'Financial returns',
                            ),
                          ],
                          onItemTap: (item) => _handleMenuTap(context, item),
                        ),
                        const SizedBox(height: AppConstants.paddingMD),
                        const _SectionLabel('System Setup'),
                        _MenuGroup(
                          items: const [
                            _MenuItem(
                              Icons.router_rounded,
                              'Setup Inverter',
                              'Configure your inverter',
                            ),
                            _MenuItem(
                              Icons.memory_rounded,
                              'Register ESP32',
                              'Register your device with backend',
                            ),
                            _MenuItem(
                              Icons.wifi_rounded,
                              'Wi-Fi Configuration',
                              'Connect to network',
                            ),
                          ],
                          onItemTap: (item) => _handleMenuTap(context, item),
                        ),
                        const SizedBox(height: AppConstants.paddingMD),
                        const _SectionLabel('Help & Support'),
                        _MenuGroup(
                          items: [
                            _MenuItem(
                              Icons.notifications_outlined,
                              'Notifications',
                              _notificationPrefs != null
                                  ? (_notificationPrefs!.enableAppNotifications
                                      ? 'View all alerts • Enabled'
                                      : 'Notifications disabled')
                                  : 'View all alerts',
                              notificationEnabled:
                                  _notificationPrefs?.enableAppNotifications ??
                                      true,
                            ),
                            const _MenuItem(
                              Icons.help_outline_rounded,
                              'FAQ',
                              'Common questions answered',
                            ),
                            const _MenuItem(
                              Icons.chat_bubble_outline_rounded,
                              'Contact Support',
                              'Get help from our team',
                            ),
                            const _MenuItem(
                              Icons.description_outlined,
                              'User Guide',
                              'How to use SolarConnect',
                            ),
                          ],
                          onItemTap: (item) => _handleMenuTap(context, item),
                        ),
                        const SizedBox(height: AppConstants.paddingMD),
                        const _SectionLabel('Settings'),
                        _MenuGroup(
                          items: [
                            const _MenuItem(
                              Icons.palette_outlined,
                              'Appearance',
                              'Theme and display',
                            ),
                            // Language subtitle is dynamic
                            _MenuItem(
                              Icons.language_outlined,
                              'Language',
                              lang,
                            ),
                            const _MenuItem(
                              Icons.privacy_tip_outlined,
                              'Privacy',
                              'Data and permissions',
                            ),
                          ],
                          onItemTap: (item) => _handleMenuTap(context, item),
                        ),
                        const SizedBox(height: AppConstants.paddingMD),
                        const _SectionLabel('Account'),
                        _MenuGroup(
                          items: const [
                            _MenuItem(
                              Icons.share_outlined,
                              'Share App',
                              'Invite friends',
                            ),
                            _MenuItem(
                              Icons.star_outline_rounded,
                              'Rate Us',
                              'Leave a review',
                            ),
                            _MenuItem(
                              Icons.logout_rounded,
                              'Sign Out',
                              '',
                              isDestructive: true,
                            ),
                          ],
                          onItemTap: (item) => _handleMenuTap(context, item),
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.fullName,
    required this.phoneNumber,
    required this.planLabel,
    required this.isLoading,
    required this.onEdit,
  });

  final String fullName;
  final String phoneNumber;
  final String planLabel;
  final bool isLoading;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMD),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        border: Border.all(color: cs.outline),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.2),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(width: AppConstants.paddingMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLoading ? 'Loading...' : fullName,
                  style: AppTextStyles.headingSmall,
                ),
                Text(
                  isLoading ? 'Fetching profile...' : phoneNumber,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: cs.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                if (planLabel.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      planLabel,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.edit_outlined,
              color: cs.onSurfaceVariant,
              size: 20,
            ),
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }
}

class _SystemInfoCard extends StatelessWidget {
  const _SystemInfoCard({
    required this.systemSizeKwp,
    required this.totalRevenue,
    required this.batteryCapacityKwh,
    required this.isOnline,
  });

  final double systemSizeKwp;
  final double totalRevenue;
  final double batteryCapacityKwh;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMD),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('My System', style: AppTextStyles.headingSmall),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isOnline
                      ? AppColors.success.withValues(alpha: 0.15)
                      : AppColors.error.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isOnline ? AppColors.success : AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isOnline ? 'Online' : 'Offline',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isOnline ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingMD),
          Row(
            children: [
              _infoTile(
                context,
                Icons.solar_power_rounded,
                '${systemSizeKwp.toStringAsFixed(systemSizeKwp % 1 == 0 ? 0 : 1)} kWp',
                'System Size',
                AppColors.warning,
              ),
              const SizedBox(width: AppConstants.paddingSM),
              _infoTile(
                context,
                Icons.currency_rupee_rounded,
                '₹${totalRevenue.toStringAsFixed(0)}',
                'Total Revenue',
                AppColors.success,
              ),
              const SizedBox(width: AppConstants.paddingSM),
              _infoTile(
                context,
                Icons.battery_full_rounded,
                '${batteryCapacityKwh.toStringAsFixed(batteryCapacityKwh % 1 == 0 ? 0 : 1)} kWh',
                'Battery',
                AppColors.info,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoTile(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color color,
  ) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(AppConstants.paddingSM),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelSmall.copyWith(fontSize: 10),
          ),
        ],
      ),
    ),
  );
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: AppTextStyles.labelSmall.copyWith(
          letterSpacing: 1.2,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDestructive;
  final bool? notificationEnabled;
  
  const _MenuItem(
    this.icon,
    this.title,
    this.subtitle, {
    this.isDestructive = false,
    this.notificationEnabled,
  });
}

class _MenuGroup extends StatelessWidget {
  final List<_MenuItem> items;
  final Function(String) onItemTap;
  const _MenuGroup({required this.items, required this.onItemTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        children: items.asMap().entries.map((e) {
          final i = e.key;
          final item = e.value;
          return Column(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.vertical(
                    top: i == 0
                        ? const Radius.circular(AppConstants.radiusLG)
                        : Radius.zero,
                    bottom: i == items.length - 1
                        ? const Radius.circular(AppConstants.radiusLG)
                        : Radius.zero,
                  ),
                  onTap: () => onItemTap(item.title),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingMD,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color:
                                (item.isDestructive
                                        ? AppColors.error
                                        : AppColors.primary)
                                    .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(
                              AppConstants.radiusSM,
                            ),
                          ),
                          child: Icon(
                            item.icon,
                            size: 18,
                            color: item.isDestructive
                                ? AppColors.error
                                : AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: AppConstants.paddingMD),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: item.isDestructive
                                      ? AppColors.error
                                      : cs.onSurface,
                                ),
                              ),
                              if (item.subtitle.isNotEmpty)
                                Text(
                                  item.subtitle,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        // Show badge for disabled notifications
                        if (item.notificationEnabled == false)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.warning.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              'Disabled',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.warning,
                                fontSize: 11,
                              ),
                            ),
                          )
                        else if (!item.isDestructive)
                          Icon(
                            Icons.chevron_right_rounded,
                            color: cs.onSurfaceVariant,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              if (i < items.length - 1)
                Divider(height: 1, indent: 68, color: cs.outline),
            ],
          );
        }).toList(),
      ),
    );
  }
}
