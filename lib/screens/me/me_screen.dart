import 'package:flutter/material.dart';
import '../../main.dart';
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
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final token = await ServiceLocator.instance.authService.getStoredToken();
    if (token == null || token.isEmpty) {
      final storedUser = await ServiceLocator.instance.authService.getStoredUserData();
      if (mounted) {
        setState(() {
          _userProfile = storedUser ?? {};
          _isLoadingProfile = false;
        });
      }
      return;
    }

    try {
      final response = await ServiceLocator.instance.authService.getMe(token);
      final profile = response['data'] is Map ? Map<String, dynamic>.from(response['data']) : response;
      if (mounted) {
        setState(() {
          _userProfile = profile;
          _isLoadingProfile = false;
        });
      }
    } catch (_) {
      final storedUser = await ServiceLocator.instance.authService.getStoredUserData();
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
    final value = _userProfile['phoneNumber'] ?? _userProfile['phone'] ?? _userProfile['mobile'];
    final text = value?.toString().trim();
    return text != null && text.isNotEmpty ? text : 'No phone number';
  }

  String get _planLabel {
    final label = _userProfile['plan'] ?? _userProfile['accountType'] ?? _userProfile['subscription'];
    final text = label?.toString().trim();
    if (text == null || text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1);
  }

  double get _systemSizeKwp {
    final value = _userProfile['systemSizeKwp'] ?? _userProfile['systemSize'] ?? 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  double get _batteryCapacityKwh {
    final value = _userProfile['batteryCapacityKwh'] ?? _userProfile['battery'] ?? 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  double get _totalRevenue {
    final value = _userProfile['totalRevenue'] ?? _userProfile['revenue'] ?? _userProfile['investmentAmount'] ?? 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  void _handleMenuTap(BuildContext context, String item) {
    switch (item) {
      case 'FAQ':
      case 'Contact Support':
      case 'User Guide':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const HelpScreen()));
        break;
      case 'Notifications':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const NotificationsScreen()));
        break;
      case 'Appearance':
      case 'Language':
      case 'Privacy':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()));
        break;
      case 'Trends':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const TrendsScreen()));
        break;
      case 'Insights':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const InsightsScreen()));
        break;
      case 'Power Cut':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const PowerCutScreen()));
        break;
      case 'Savings':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const SavingsScreen()));
        break;
      case 'Setup Inverter':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const InverterSetupScreen()));
        break;
      case 'Wi-Fi Configuration':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const WifiConfigScreen()));
        break;
      case 'Register ESP32':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const DeviceRegisterScreen()));
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
    if (confirmed == true && context.mounted) {
      AppDialogs.showSuccessSnackBar(context, 'Signed out successfully');
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
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: cs.surface,
                  title: Text('My Account', style: AppTextStyles.headingMedium),
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
                      ),
                      const SizedBox(height: AppConstants.paddingMD),
                      _SystemInfoCard(
                        systemSizeKwp: _systemSizeKwp,
                        totalRevenue: _totalRevenue,
                        batteryCapacityKwh: _batteryCapacityKwh,
                      ),
                      const SizedBox(height: AppConstants.paddingMD),
                      const _SectionLabel('Analytics & Monitoring'),
                      _MenuGroup(
                        items: const [
                          _MenuItem(Icons.trending_up_rounded, 'Trends',
                              'View historical data'),
                          _MenuItem(Icons.insights_rounded, 'Insights',
                              'Performance analysis'),
                          _MenuItem(Icons.power_off_rounded, 'Power Cut',
                              'Power outage tracking'),
                          _MenuItem(Icons.savings_rounded, 'Savings',
                              'Financial returns'),
                        ],
                        onItemTap: (item) => _handleMenuTap(context, item),
                      ),
                      const SizedBox(height: AppConstants.paddingMD),
                      const _SectionLabel('System Setup'),
                      _MenuGroup(
                        items: const [
                          _MenuItem(Icons.router_rounded, 'Setup Inverter',
                              'Configure your inverter'),
                          _MenuItem(Icons.memory_rounded, 'Register ESP32',
                              'Register your device with backend'),
                          _MenuItem(Icons.wifi_rounded, 'Wi-Fi Configuration',
                              'Connect to network'),
                        ],
                        onItemTap: (item) => _handleMenuTap(context, item),
                      ),
                      const SizedBox(height: AppConstants.paddingMD),
                      const _SectionLabel('Help & Support'),
                      _MenuGroup(
                        items: const [
                          _MenuItem(Icons.notifications_outlined, 'Notifications',
                              'View all alerts'),
                          _MenuItem(Icons.help_outline_rounded, 'FAQ',
                              'Common questions answered'),
                          _MenuItem(Icons.chat_bubble_outline_rounded,
                              'Contact Support', 'Get help from our team'),
                          _MenuItem(Icons.description_outlined, 'User Guide',
                              'How to use SolarConnect'),
                        ],
                        onItemTap: (item) => _handleMenuTap(context, item),
                      ),
                      const SizedBox(height: AppConstants.paddingMD),
                      const _SectionLabel('Settings'),
                      _MenuGroup(
                        items: [
                          const _MenuItem(Icons.palette_outlined, 'Appearance',
                              'Theme and display'),
                          // Language subtitle is dynamic
                          _MenuItem(
                              Icons.language_outlined, 'Language', lang),
                          const _MenuItem(Icons.privacy_tip_outlined,
                              'Privacy', 'Data and permissions'),
                        ],
                        onItemTap: (item) => _handleMenuTap(context, item),
                      ),
                      const SizedBox(height: AppConstants.paddingMD),
                      const _SectionLabel('Account'),
                      _MenuGroup(
                        items: const [
                          _MenuItem(
                              Icons.share_outlined, 'Share App', 'Invite friends'),
                          _MenuItem(Icons.star_outline_rounded, 'Rate Us',
                              'Leave a review'),
                          _MenuItem(Icons.logout_rounded, 'Sign Out', '',
                              isDestructive: true),
                        ],
                        onItemTap: (item) => _handleMenuTap(context, item),
                      ),
                    ]),
                  ),
                ),
              ],
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
  });

  final String fullName;
  final String phoneNumber;
  final String planLabel;
  final bool isLoading;

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
                  color: AppColors.primary.withValues(alpha: 0.5), width: 2),
            ),
            child:
                const Icon(Icons.person_rounded, color: AppColors.primary, size: 32),
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
                  style: AppTextStyles.bodySmall
                      .copyWith(color: cs.onSurfaceVariant, fontSize: 12),
                ),
                if (planLabel.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      planLabel,
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.success),
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit_outlined,
                color: cs.onSurfaceVariant, size: 20),
            onPressed: () {},
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
  });

  final double systemSizeKwp;
  final double totalRevenue;
  final double batteryCapacityKwh;

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
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                          color: AppColors.success, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 4),
                    Text('Online',
                        style: AppTextStyles.labelSmall
                            .copyWith(color: AppColors.success)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingMD),
          Row(
            children: [
              _infoTile(context, Icons.solar_power_rounded,
                  '${systemSizeKwp.toStringAsFixed(systemSizeKwp % 1 == 0 ? 0 : 1)} kWp',
                  'System Size', AppColors.warning),
              const SizedBox(width: AppConstants.paddingSM),
              _infoTile(context, Icons.currency_rupee_rounded,
                  '₹${totalRevenue.toStringAsFixed(0)}',
                  'Total Revenue', AppColors.success),
              const SizedBox(width: AppConstants.paddingSM),
              _infoTile(context, Icons.battery_full_rounded,
                  '${batteryCapacityKwh.toStringAsFixed(batteryCapacityKwh % 1 == 0 ? 0 : 1)} kWh',
                  'Battery', AppColors.info),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoTile(BuildContext context, IconData icon, String value,
          String label, Color color) =>
      Expanded(
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
      child: Text(text.toUpperCase(),
          style: AppTextStyles.labelSmall.copyWith(
              letterSpacing: 1.2,
              color: Theme.of(context).colorScheme.onSurfaceVariant)),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDestructive;
  const _MenuItem(this.icon, this.title, this.subtitle,
      {this.isDestructive = false});
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
                        horizontal: AppConstants.paddingMD, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: (item.isDestructive
                                    ? AppColors.error
                                    : AppColors.primary)
                                .withValues(alpha: 0.12),
                            borderRadius:
                                BorderRadius.circular(AppConstants.radiusSM),
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
                                Text(item.subtitle,
                                    style: AppTextStyles.bodySmall.copyWith(
                                        color: cs.onSurfaceVariant)),
                            ],
                          ),
                        ),
                        if (!item.isDestructive)
                          Icon(Icons.chevron_right_rounded,
                              color: cs.onSurfaceVariant, size: 20),
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
