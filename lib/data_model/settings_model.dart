import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsModel extends ChangeNotifier {
  static late SharedPreferences _prefs;

  static const _keyPrimaryLabel = 'counter_primary_label';
  static const _keySecondaryLabel = 'counter_secondary_label';
  static const _keyThemeMode = 'theme_mode';
  static const _keyFamilyCardColor = 'family_card_color';
  static const _keyFamilyTextColor = 'family_text_color';
  static const _keyFamilyCardTextSwap = 'family_card_text_swap';

  static const _defaultPrimaryLabel = 'Mala';
  static const _defaultSecondaryLabel = 'Jap';

  String _primaryLabel = _defaultPrimaryLabel;
  String _secondaryLabel = _defaultSecondaryLabel;
  ThemeMode _themeMode = ThemeMode.system;
  Color? _familyCardColor;
  Color? _familyTextColor;
  bool _familyCardTextSwap = false;

  SettingsModel();

  static Future<SettingsModel> getInstance() async {
    _prefs = await SharedPreferences.getInstance();
    final model = SettingsModel();
    model._primaryLabel =
        _prefs.getString(_keyPrimaryLabel) ?? _defaultPrimaryLabel;
    model._secondaryLabel =
        _prefs.getString(_keySecondaryLabel) ?? _defaultSecondaryLabel;
    final themeModeString = _prefs.getString(_keyThemeMode);
    model._themeMode = _themeModeFromString(themeModeString);
    model._familyCardColor = _colorFromPrefs(
      _prefs.getInt(_keyFamilyCardColor),
    );
    model._familyTextColor = _colorFromPrefs(
      _prefs.getInt(_keyFamilyTextColor),
    );
    model._familyCardTextSwap = _prefs.getBool(_keyFamilyCardTextSwap) ?? false;
    return model;
  }

  String get primaryLabel => _primaryLabel;
  String get secondaryLabel => _secondaryLabel;
  ThemeMode get themeMode => _themeMode;
  Color? get familyCardColor => _familyCardColor;
  Color? get familyTextColor => _familyTextColor;
  bool get familyCardTextSwap => _familyCardTextSwap;

  set primaryLabel(String value) {
    _primaryLabel = value.trim().isEmpty ? _defaultPrimaryLabel : value.trim();
    _prefs.setString(_keyPrimaryLabel, _primaryLabel);
    notifyListeners();
  }

  set secondaryLabel(String value) {
    _secondaryLabel = value.trim().isEmpty
        ? _defaultSecondaryLabel
        : value.trim();
    _prefs.setString(_keySecondaryLabel, _secondaryLabel);
    notifyListeners();
  }

  set themeMode(ThemeMode mode) {
    _themeMode = mode;
    _prefs.setString(_keyThemeMode, _stringFromThemeMode(mode));
    notifyListeners();
  }

  set familyCardColor(Color? color) {
    _familyCardColor = color;
    if (color == null) {
      _prefs.remove(_keyFamilyCardColor);
    } else {
      _prefs.setInt(_keyFamilyCardColor, color.toARGB32());
    }
    notifyListeners();
  }

  set familyTextColor(Color? color) {
    _familyTextColor = color;
    if (color == null) {
      _prefs.remove(_keyFamilyTextColor);
    } else {
      _prefs.setInt(_keyFamilyTextColor, color.toARGB32());
    }
    notifyListeners();
  }

  set familyCardTextSwap(bool value) {
    _familyCardTextSwap = value;
    _prefs.setBool(_keyFamilyCardTextSwap, value);
    notifyListeners();
  }

  static ThemeMode _themeModeFromString(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static String _stringFromThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
  }

  static Color? _colorFromPrefs(int? value) {
    if (value == null) return null;
    try {
      return Color(value);
    } catch (_) {
      return null;
    }
  }
}
