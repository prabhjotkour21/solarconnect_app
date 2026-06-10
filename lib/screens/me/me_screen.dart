import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_dialogs.dart';
import 'settings_screen.dart';
import 'help_screen.dart';

class MeScreen extends StatelessWidget {
  const MeScreen({super.key});

  void _handleMenuTap(BuildContext context, String item) {
    switch (item) {
      case 'FAQ':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HelpScreen()),
        );
        break;
      case 'Contact Support':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HelpScreen()),
        );
        break;
      case 'User Guide':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HelpScreen()),
        );
        break;
      case 'Notifications':
      case 'Appearance':
      case 'Language':
      case 'Privacy':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingsScreen()),
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
    if (confirmed == true) {
      AppDialogs.showSuccessSnackBar(context, 'Signed out successfully');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.backgroundDark,
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
                _ProfileHeader(),
                const SizedBox(height: AppConstants.paddingMD),
                _SystemInfoCard(),
                const SizedBox(height: AppConstants.paddingMD),
                _SectionLabel('Help & Support'),
                _MenuGroup(
                  items: const [
                    _MenuItem(Icons.help_outline_rounded, 'FAQ', 'Common questions answered'),
                    _MenuItem(Icons.chat_bubble_outline_rounded, 'Contact Support', 'Get help from our team'),
                    _MenuItem(Icons.description_outlined, 'User Guide', 'How to use SolarConnect'),
                  ],
                  onItemTap: (item) => _handleMenuTap(context, item),
                ),
                const SizedBox(height: AppConstants.paddingMD),
                _SectionLabel('Settings'),
                _MenuGroup(
                  items: const [
                    _MenuItem(Icons.notifications_outlined, 'Notifications', 'Alerts and reminders'),
                    _MenuItem(Icons.palette_outlined, 'Appearance', 'Theme and display'),
                    _MenuItem(Icons.language_outlined, 'Language', 'English'),
                    _MenuItem(Icons.privacy_tip_outlined, 'Privacy', 'Data and permissions'),
                  ],
                  onItemTap: (item) => _handleMenuTap(context, item),
                ),
                const SizedBox(height: AppConstants.paddingMD),
                _SectionLabel('Account'),
                _MenuGroup(
                  items: const [
                    _MenuItem(Icons.share_outlined, 'Share App', 'Invite friends'),
                    _MenuItem(Icons.star_outline_rounded, 'Rate Us', 'Leave a review'),
                    _MenuItem(Icons.logout_rounded, 'Sign Out', '', isDestructive: true),
                  ],
                  onItemTap: (item) => _handleMenuTap(context, item),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.2),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.5), width: 2),
            ),
            child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 32),
          ),
          const SizedBox(width: AppConstants.paddingMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Alex Johnson', style: AppTextStyles.headingSmall),
                Text('alex@example.com',
                    style: AppTextStyles.bodySmall.copyWith(fontSize: 12)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Premium',
                      style: AppTextStyles.labelSmall.copyWith(color: AppColors.success)),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.textSecondary, size: 20),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _SystemInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        border: Border.all(color: AppColors.divider),
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
                        style:
                            AppTextStyles.labelSmall.copyWith(color: AppColors.success)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingMD),
          Row(
            children: [
              _infoTile(Icons.solar_power_rounded, '10 kWp', 'System Size',
                  AppColors.warning),
              const SizedBox(width: AppConstants.paddingSM),
              _infoTile(Icons.battery_full_rounded, '13.5 kWh', 'Battery',
                  AppColors.success),
              const SizedBox(width: AppConstants.paddingSM),
              _infoTile(Icons.location_on_rounded, 'Sydney', 'Location',
                  AppColors.info),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String value, String label, Color color) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(AppConstants.paddingSM),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppConstants.radiusMD),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(height: 4),
              Text(value,
                  style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
              Text(label, style: AppTextStyles.labelSmall.copyWith(fontSize: 10)),
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
              letterSpacing: 1.2, color: AppColors.textSecondary)),
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        border: Border.all(color: AppColors.divider),
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
                    top: i == 0 ? const Radius.circular(AppConstants.radiusLG) : Radius.zero,
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
                            color: (item.isDestructive ? AppColors.error : AppColors.primary)
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                          ),
                          child: Icon(
                            item.icon,
                            size: 18,
                            color: item.isDestructive ? AppColors.error : AppColors.primary,
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
                                      : AppColors.textPrimary,
                                ),
                              ),
                              if (item.subtitle.isNotEmpty)
                                Text(item.subtitle, style: AppTextStyles.bodySmall),
                            ],
                          ),
                        ),
                        if (!item.isDestructive)
                          const Icon(Icons.chevron_right_rounded,
                              color: AppColors.textSecondary, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
              if (i < items.length - 1)
                const Divider(height: 1, indent: 68, color: AppColors.divider),
            ],
          );
        }).toList(),
      ),
    );
  }
}
