import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/shell/shell_screen.dart';

// Global notifiers — settings screen writes to these, app rebuilds
final ValueNotifier<ThemeMode> appThemeMode = ValueNotifier(ThemeMode.dark);
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
        home: const ShellScreen(),
      ),
    );
  }
}
