import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleModel extends ChangeNotifier {
  static late SharedPreferences _sharedPref;
  static const languageKey = 'language';
  static const defaultLanguage = 'en';

  Locale _locale;

  LocaleModel(this._locale);

  static Future<LocaleModel> getInstance() async {
    _sharedPref = await SharedPreferences.getInstance();
    var language = _sharedPref.getString(languageKey);
    if (language == null || language.isEmpty) {
      language = defaultLanguage;
    }
    return LocaleModel(Locale(language));
  }

  Locale get locale => _locale;

  void set(Locale locale) {
    _locale = locale;
    _sharedPref.setString(languageKey, locale.languageCode);
    notifyListeners();
  }
}
