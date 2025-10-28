// lib/providers/theme_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themePrefKey = 'theme_preference';
  ThemeMode _themeMode;

  ThemeProvider() : _themeMode = ThemeMode.system {
    _loadThemePreference();
  }

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      return SchedulerBinding.instance.window.platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  void toggleTheme(bool isOn) {
    _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    _saveThemePreference();
    notifyListeners();
  }

  void _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themePrefKey) ?? 0; // 0 for system, 1 for light, 2 for dark
    switch (themeIndex) {
      case 1:
        _themeMode = ThemeMode.light;
        break;
      case 2:
        _themeMode = ThemeMode.dark;
        break;
      default:
        _themeMode = ThemeMode.system;
        break;
    }
    notifyListeners();
  }

  void _saveThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    int themeIndex;
    switch (_themeMode) {
      case ThemeMode.light:
        themeIndex = 1;
        break;
      case ThemeMode.dark:
        themeIndex = 2;
        break;
      default:
        themeIndex = 0;
        break;
    }
    await prefs.setInt(_themePrefKey, themeIndex);
  }

  ThemeData getTheme() {
    final bool useDarkMode = isDarkMode;
    return ThemeData(
      brightness: useDarkMode ? Brightness.dark : Brightness.light,
      primarySwatch: Colors.teal,
      // Add other theme properties here
    );
  }
}
