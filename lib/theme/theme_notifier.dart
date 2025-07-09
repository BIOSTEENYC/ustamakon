import 'package:flutter/material.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Color? _customPrimaryColor;

  ThemeMode get themeMode => _themeMode;
  Color? get customPrimaryColor => _customPrimaryColor;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setSystemTheme() {
    _themeMode = ThemeMode.system;
    _customPrimaryColor = null;
    notifyListeners();
  }

  void setCustomPrimaryColor(Color color) {
    _customPrimaryColor = color;
    notifyListeners();
  }
}
