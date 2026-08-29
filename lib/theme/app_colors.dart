import 'package:flutter/material.dart';

/// Every color token used in SolarConnect.
///
/// Rule: never hardcode a color in a widget. Always reference it from here.
/// This makes theming, dark mode, and rebranding trivial.
abstract class AppColors {
  static bool get _isDarkMode => themeMode.value == ThemeMode.dark;
  static final ValueNotifier<ThemeMode> themeMode =
      ValueNotifier(ThemeMode.dark);

  // ── Brand ──────────────────────────────────────────────────────────────────
  // Solar orange — the primary action color (buttons, highlights, active tab)
  static const Color primary = Color(0xFFFF6B2C);
  static const Color primaryLight = Color(0xFFFF8F5E);
  static const Color primaryDark = Color(0xFFD94F10);

  // Deep space blue — used for backgrounds, giving a "premium energy" feel
  static const Color _backgroundDark = Color(0xFF0D1B2A);
  static const Color _surfaceDark = Color(0xFF1A2D42);
  static const Color _cardDark = Color(0xFF1E3348);

  static Color get backgroundDark => _isDarkMode ? _backgroundDark : backgroundLight;
  static Color get surfaceDark => _isDarkMode ? _surfaceDark : surfaceLight;
  static Color get cardDark => _isDarkMode ? _cardDark : cardLight;

  // ── Semantic colors ────────────────────────────────────────────────────────
  static const Color success = Color(0xFF4CAF82);   // Solar producing — green
  static const Color warning = Color(0xFFFFB74D);   // Low battery — amber
  static const Color error = Color(0xFFEF5350);     // Fault / offline — red
  static const Color info = Color(0xFF42A5F5);      // Grid import — blue

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color _textPrimaryDark = Color(0xFFF0F4F8);
  static const Color _textSecondaryDark = Color(0xFF8FA3B1);
  static const Color _textDisabledDark = Color(0xFF4A6070);

  static Color get textPrimary => _isDarkMode ? _textPrimaryDark : textPrimaryLight;
  static Color get textSecondary => _isDarkMode ? _textSecondaryDark : textSecondaryLight;
  static Color get textDisabled => _isDarkMode ? _textDisabledDark : textSecondaryLight;

  // ── Chart gradient stops ───────────────────────────────────────────────────
  static const Color chartGradientTop = Color(0x66FF6B2C);    // 40% opacity
  static const Color chartGradientBottom = Color(0x00FF6B2C); // 0% opacity

  // ── Divider / border ──────────────────────────────────────────────────────
  static const Color _dividerDark = Color(0xFF253D52);
  static Color get divider => _isDarkMode ? _dividerDark : const Color(0xFFCDD5DB);

  // ── Aliases (for compatibility with newer screens) ────────────────────────
  static const Color primaryOrange = primary;
  static Color get primaryText => textPrimary;
  static Color get secondaryText => textSecondary;
  static Color get dividerColor => divider;
  static const Color successGreen = success;
  static const Color errorRed = error;

  // ── Light theme equivalents (for future light mode support) ───────────────
  static const Color backgroundLight = Color(0xFFF5F7FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF0D1B2A);
  static const Color textSecondaryLight = Color(0xFF5A7080);
}
