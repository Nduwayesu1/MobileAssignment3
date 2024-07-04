import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  late ThemeData _themeData;
  final String _themePreferenceKey = 'theme_preference';

  ThemeProvider() {
    _loadTheme(); // Load theme from SharedPreferences asynchronously
  }

  ThemeData getTheme() => _themeData;

  Future<void> toggleTheme() async {
    await _loadTheme(); // Ensure theme is loaded before toggling
    _themeData = _themeData.brightness == Brightness.dark
        ? ThemeData.light()
        : ThemeData.dark();
    await _saveTheme(_themeData.brightness == Brightness.dark);
    notifyListeners();
  }

  Color getBackgroundColor() {
    if (_themeData.brightness == Brightness.dark) {
      // Dark theme background color
      return Colors.grey[900]!;
    } else {
      // Light theme background color
      return Colors.white;
    }
  }

  Future<void> _saveTheme(bool isDarkMode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themePreferenceKey, isDarkMode);
  }

  Future<void> _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isDarkMode = prefs.getBool(_themePreferenceKey) ?? false;
    _themeData = isDarkMode ? ThemeData.dark() : ThemeData.light();
    notifyListeners();
  }
}
