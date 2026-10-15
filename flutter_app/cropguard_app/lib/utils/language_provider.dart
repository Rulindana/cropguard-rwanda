import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'translations.dart';

class LanguageProvider extends ChangeNotifier {
  static const _key = 'language_code';
  AppStrings _strings = AppStrings.en;

  AppStrings get strings => _strings;
  String get code => _strings.languageCode;

  LanguageProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key) ?? 'en';
    _strings = AppStrings.fromCode(saved);
    notifyListeners();
  }

  Future<void> setLanguage(String code) async {
    _strings = AppStrings.fromCode(code);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, code);
  }
}
