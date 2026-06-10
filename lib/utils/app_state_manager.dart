import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global app state manager for theme, language, and user preferences
class AppStateManager extends ChangeNotifier {
  static final AppStateManager _instance = AppStateManager._internal();
  static late SharedPreferences _prefs;

  bool _isDarkMode = true;
  String _selectedLanguage = 'English';

  AppStateManager._internal();

  factory AppStateManager() {
    return _instance;
  }

  // Getters
  bool get isDarkMode => _isDarkMode;
  String get selectedLanguage => _selectedLanguage;

  // Initialize preferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _instance._isDarkMode = _prefs.getBool('isDarkMode') ?? true;
    _instance._selectedLanguage = _prefs.getString('language') ?? 'English';
  }

  // Toggle theme
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  // Set theme
  Future<void> setTheme(bool isDark) async {
    _isDarkMode = isDark;
    await _prefs.setBool('isDarkMode', isDark);
    notifyListeners();
  }

  // Change language
  Future<void> setLanguage(String language) async {
    _selectedLanguage = language;
    await _prefs.setString('language', language);
    notifyListeners();
  }

  // Get greeting based on language
  String getGreeting() {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
            ? 'Good Afternoon'
            : 'Good Evening';

    return _selectedLanguage == 'Hindi'
        ? _getHindiGreeting(greeting)
        : greeting;
  }

  String _getHindiGreeting(String greeting) {
    switch (greeting) {
      case 'Good Morning':
        return 'सुप्रभात';
      case 'Good Afternoon':
        return 'नमस्कार';
      case 'Good Evening':
        return 'शुभ संध्या';
      default:
        return 'नमस्ते';
    }
  }

  // Translate common terms
  String translate(String key) {
    const translations = {
      'overview': {'en': 'Overview', 'hi': 'अवलोकन'},
      'explore': {'en': 'Explore', 'hi': 'खोजें'},
      'account': {'en': 'Account', 'hi': 'खाता'},
      'settings': {'en': 'Settings', 'hi': 'सेटिंग्स'},
      'language': {'en': 'Language', 'hi': 'भाषा'},
      'theme': {'en': 'Theme', 'hi': 'थीम'},
      'notifications': {'en': 'Notifications', 'hi': 'सूचनाएं'},
      'help': {'en': 'Help', 'hi': 'मदद'},
      'signout': {'en': 'Sign Out', 'hi': 'साइन आउट'},
    };

    final lang = _selectedLanguage == 'Hindi' ? 'hi' : 'en';
    return translations[key]?[lang] ?? key;
  }
}
