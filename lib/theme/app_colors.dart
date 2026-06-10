import 'package:flutter/material.dart';

/// Every color token used in SolarConnect.
///
/// Rule: never hardcode a color in a widget. Always reference it from here.
/// This makes theming, dark mode, and rebranding trivial.
abstract class AppColors {
  // ── Brand ──────────────────────────────────────────────────────────────────
  // Solar orange — the primary action color (buttons, highlights, active tab)
  static const Color primary = Color(0xFFFF6B2C);
  static const Color primaryLight = Color(0xFFFF8F5E);
  static const Color primaryDark = Color(0xFFD94F10);

  // Deep space blue — used for backgrounds, giving a "premium energy" feel
  static const Color backgroundDark = Color(0xFF0D1B2A);
  static const Color surfaceDark = Color(0xFF1A2D42);
  static const Color cardDark = Color(0xFF1E3348);

  // ── Semantic colors ────────────────────────────────────────────────────────
  static const Color success = Color(0xFF4CAF82);   // Solar producing — green
  static const Color warning = Color(0xFFFFB74D);   // Low battery — amber
  static const Color error = Color(0xFFEF5350);     // Fault / offline — red
  static const Color info = Color(0xFF42A5F5);      // Grid import — blue

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF0F4F8);
  static const Color textSecondary = Color(0xFF8FA3B1);
  static const Color textDisabled = Color(0xFF4A6070);

  // ── Chart gradient stops ───────────────────────────────────────────────────
  static const Color chartGradientTop = Color(0x66FF6B2C);    // 40% opacity
  static const Color chartGradientBottom = Color(0x00FF6B2C); // 0% opacity

  // ── Divider / border ──────────────────────────────────────────────────────
  static const Color divider = Color(0xFF253D52);

  // ── Light theme equivalents (for future light mode support) ───────────────
  static const Color backgroundLight = Color(0xFFF5F7FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF0D1B2A);
  static const Color textSecondaryLight = Color(0xFF5A7080);
}
