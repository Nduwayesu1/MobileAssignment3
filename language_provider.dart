import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  Locale? _appLocale;

  // Getter to fetch current locale
  Locale? get appLocale => _appLocale;

  // Function to initialize language settings
  Future<void> initializeLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('languageCode');
    String? countryCode = prefs.getString('countryCode');
    if (languageCode != null && countryCode != null) {
      _appLocale = Locale(languageCode, countryCode);
    } else {
      _appLocale = null;
    }
    notifyListeners();
  }

  // Function to change app language
  Future<void> changeLanguage(Locale locale) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_appLocale != locale) {
      _appLocale = locale;
      await prefs.setString('languageCode', locale.languageCode);
      await prefs.setString('countryCode', locale.countryCode ?? '');
      notifyListeners();
    }
  }

  // Function to get list of supported locales
  List<Locale> getSupportedLocales() {
    return [
      const Locale('en', 'US'),
      const Locale('fr', 'FR'),
      // Add more locales as needed
    ];
  }

  // Function to get list of supported languages
  List<String> getSupportedLanguages() {
    return getSupportedLocales().map((locale) => locale.languageCode).toList();
  }
}
