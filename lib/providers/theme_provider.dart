import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  // --- بداية التعديل 1: إضافة متغيرات للتحكم بالخلفية ---
  bool _showBackgroundPattern = true; 

  bool get isDarkMode => _isDarkMode;
  bool get showBackgroundPattern => _showBackgroundPattern;
  // --- نهاية التعديل 1 ---

  ThemeProvider() {
    _loadTheme();
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    // --- بداية التعديل 2: تحميل إعداد الخلفية المحفوظ ---
    _showBackgroundPattern = prefs.getBool('showBackgroundPattern') ?? true;
    // --- نهاية التعديل 2 ---
    notifyListeners();
  }

  void toggleTheme(bool isOn) async {
    _isDarkMode = isOn;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', _isDarkMode);
  }

  // --- بداية التعديل 3: دالة جديدة لتغيير حالة الخلفية ---
  void toggleBackgroundPattern(bool isOn) async {
    _showBackgroundPattern = isOn;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('showBackgroundPattern', _showBackgroundPattern);
  }
  // --- نهاية التعديل 3 ---
}
