import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'routes/app_routes.dart';
import 'screens/shell/shell_screen.dart';
import 'screens/explore/article_detail_screen.dart';
import 'screens/me/settings_screen.dart';
import 'screens/me/help_screen.dart';
import 'models/explore_article.dart';

void main() {
  runApp(const SolarConnectApp());
}

class SolarConnectApp extends StatelessWidget {
  const SolarConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SolarConnect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      home: const ShellScreen(),
    );
  }
}
