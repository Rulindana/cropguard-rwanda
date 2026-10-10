import 'package:flutter/material.dart';
import 'translations.dart';

class LanguageProvider extends ChangeNotifier {
  AppStrings _strings = AppStrings.en;

  AppStrings get strings => _strings;
  String get code => _strings.languageCode;

  void setLanguage(String code) {
    _strings = AppStrings.fromCode(code);
    notifyListeners();
  }
}
