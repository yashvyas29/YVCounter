import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yv_counter/l10n/app_localizations.dart';

class SettingsModel extends ChangeNotifier {
  static late SharedPreferences _prefs;

  static const _keyPrimaryLabel = 'counter_primary_label';
  static const _keySecondaryLabel = 'counter_secondary_label';
  static const _keyThemeMode = 'theme_mode';
  static const _keyFamilyCardColor = 'family_card_color';
  static const _keyFamilyTextColor = 'family_text_color';
  static const _keyFamilyCardTextSwap = 'family_card_text_swap';
  static const _keyJapsPerMala = 'japs_per_mala';
  static const _keyDailyMalaTarget = 'daily_mala_target';
  static const _keyReminderEnabled = 'reminder_enabled';
  static const _keyReminderHour = 'reminder_hour';
  static const _keyReminderMinute = 'reminder_minute';

  // Fallback defaults (English)
  static const _fallbackPrimaryLabel = 'Mala';
  static const _fallbackSecondaryLabel = 'Jap';
  static const _defaultJapsPerMala = 108;
  static const _defaultDailyMalaTarget = 0;
  static const _defaultReminderHour = 8;
  static const _defaultReminderMinute = 0;

  /// Returns the localized default primary label based on the current locale.
  static String getDefaultPrimaryLabel(BuildContext? context) {
    if (context != null) {
      return AppLocalizations.of(context).mala;
    }
    // Fallback to English if no context
    return _fallbackPrimaryLabel;
  }

  /// Returns the localized default secondary label based on the current locale.
  static String getDefaultSecondaryLabel(BuildContext? context) {
    if (context != null) {
      return AppLocalizations.of(context).jap;
    }
    // Fallback to English if no context
    return _fallbackSecondaryLabel;
  }

  String _primaryLabel = _fallbackPrimaryLabel;
  String _secondaryLabel = _fallbackSecondaryLabel;
  ThemeMode _themeMode = ThemeMode.system;
  Color? _familyCardColor;
  Color? _familyTextColor;
  bool _familyCardTextSwap = false;
  int _japsPerMala = _defaultJapsPerMala;
  int _dailyMalaTarget = _defaultDailyMalaTarget;
  bool _reminderEnabled = false;
  int _reminderHour = _defaultReminderHour;
  int _reminderMinute = _defaultReminderMinute;

  SettingsModel();

  static Future<SettingsModel> getInstance() async {
    _prefs = await SharedPreferences.getInstance();
    final model = SettingsModel();
    model._primaryLabel =
        _prefs.getString(_keyPrimaryLabel) ?? _fallbackPrimaryLabel;
    model._secondaryLabel =
        _prefs.getString(_keySecondaryLabel) ?? _fallbackSecondaryLabel;
    final themeModeString = _prefs.getString(_keyThemeMode);
    model._themeMode = _themeModeFromString(themeModeString);
    model._familyCardColor = _colorFromPrefs(
      _prefs.getInt(_keyFamilyCardColor),
    );
    model._familyTextColor = _colorFromPrefs(
      _prefs.getInt(_keyFamilyTextColor),
    );
    model._familyCardTextSwap = _prefs.getBool(_keyFamilyCardTextSwap) ?? false;
    model._japsPerMala = _prefs.getInt(_keyJapsPerMala) ?? _defaultJapsPerMala;
    model._dailyMalaTarget =
        _prefs.getInt(_keyDailyMalaTarget) ?? _defaultDailyMalaTarget;
    model._reminderEnabled = _prefs.getBool(_keyReminderEnabled) ?? false;
    model._reminderHour =
        _prefs.getInt(_keyReminderHour) ?? _defaultReminderHour;
    model._reminderMinute =
        _prefs.getInt(_keyReminderMinute) ?? _defaultReminderMinute;
    return model;
  }

  String get primaryLabel => _primaryLabel;
  String get secondaryLabel => _secondaryLabel;

  /// Returns true if primary label is at its default fallback value.
  bool get isPrimaryLabelDefault => _primaryLabel == _fallbackPrimaryLabel;

  /// Returns true if secondary label is at its default fallback value.
  bool get isSecondaryLabelDefault =>
      _secondaryLabel == _fallbackSecondaryLabel;

  /// Returns the primary label, using localized default when at fallback.
  /// Requires a BuildContext to access AppLocalizations.
  String getLocalizedPrimaryLabel(BuildContext context) {
    if (isPrimaryLabelDefault) {
      return AppLocalizations.of(context).mala;
    }
    return _primaryLabel;
  }

  /// Returns the secondary label, using localized default when at fallback.
  /// Requires a BuildContext to access AppLocalizations.
  String getLocalizedSecondaryLabel(BuildContext context) {
    if (isSecondaryLabelDefault) {
      return AppLocalizations.of(context).jap;
    }
    return _secondaryLabel;
  }

  ThemeMode get themeMode => _themeMode;
  Color? get familyCardColor => _familyCardColor;
  Color? get familyTextColor => _familyTextColor;
  bool get familyCardTextSwap => _familyCardTextSwap;
  int get japsPerMala => _japsPerMala;
  int get dailyMalaTarget => _dailyMalaTarget;
  bool get reminderEnabled => _reminderEnabled;
  TimeOfDay get reminderTime =>
      TimeOfDay(hour: _reminderHour, minute: _reminderMinute);

  set primaryLabel(String value) {
    _primaryLabel = value.trim().isEmpty ? _fallbackPrimaryLabel : value.trim();
    _prefs.setString(_keyPrimaryLabel, _primaryLabel);
    notifyListeners();
  }

  set secondaryLabel(String value) {
    _secondaryLabel = value.trim().isEmpty
        ? _fallbackSecondaryLabel
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

  set japsPerMala(int value) {
    _japsPerMala = value > 0 ? value : _defaultJapsPerMala;
    _prefs.setInt(_keyJapsPerMala, _japsPerMala);
    notifyListeners();
  }

  set dailyMalaTarget(int value) {
    _dailyMalaTarget = value >= 0 ? value : 0;
    _prefs.setInt(_keyDailyMalaTarget, _dailyMalaTarget);
    notifyListeners();
  }

  set reminderEnabled(bool value) {
    _reminderEnabled = value;
    _prefs.setBool(_keyReminderEnabled, value);
    notifyListeners();
  }

  void setReminderTime(TimeOfDay time) {
    _reminderHour = time.hour;
    _reminderMinute = time.minute;
    _prefs.setInt(_keyReminderHour, time.hour);
    _prefs.setInt(_keyReminderMinute, time.minute);
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
