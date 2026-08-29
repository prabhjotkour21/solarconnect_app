import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/shell/shell_screen.dart';
import 'screens/trends_screen.dart';
import 'screens/insights_screen.dart';
import 'screens/power_cut_screen.dart';
import 'screens/savings_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/inverter_setup_screen.dart';
import 'screens/wifi_config_screen.dart';
import 'theme/app_colors.dart';

// Global notifiers — settings screen writes to these, app rebuilds
final ValueNotifier<ThemeMode> appThemeMode = AppColors.themeMode;
final ValueNotifier<String> appLanguage = ValueNotifier('English');

void main() {
  runApp(const SolarConnectApp());
}

class SolarConnectApp extends StatelessWidget {
  const SolarConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeMode,
      builder: (_, mode, __) => MaterialApp(
        title: 'SolarConnect',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: mode,
        home: const SplashScreen(),
        routes: {
          '/home': (context) => const ShellScreen(),
          '/login': (context) => const LoginScreen(),
          '/trends': (context) => const TrendsScreen(),
          '/insights': (context) => const InsightsScreen(),
          '/power_cut': (context) => const PowerCutScreen(),
          '/savings': (context) => const SavingsScreen(),
          '/notifications': (context) => const NotificationsScreen(),
          '/inverter_setup': (context) => const InverterSetupScreen(),
          '/wifi_config': (context) => const WifiConfigScreen(),
        },
      ),
    );
  }
}
