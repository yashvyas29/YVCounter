# Architecture Guide

**Project**: YVCounter (YVMalaJapCounter)
**Style**: Feature-Modular with shared utilities layer
**Language**: Dart 3.11.1 | **Framework**: Flutter 3.41.4

---

## Architecture Overview

```
┌─────────────────────────────────────────┐
│              Flutter UI Layer           │
│  mala_japs/  family_members/  settings/ │
│  famity_tree/  about_page.dart          │
└────────────────┬────────────────────────┘
                 │ uses
┌────────────────▼────────────────────────┐
│            Data Models Layer            │
│  data_model/  (Mala, User, TreeMember,  │
│   SettingsModel, LocaleModel)           │
└────────────────┬────────────────────────┘
                 │ uses
┌────────────────▼────────────────────────┐
│          Common / Services Layer        │
│  common/  (sqlite_db_provider,          │
│   shared_pref, google_drive,            │
│   json_file_handler, image handlers)    │
└─────────────────────────────────────────┘
```

**Key Decision**: Feature folders contain their own UI and state logic; shared infrastructure lives in `common/`; data models in `data_model/`. Keeps features self-contained and common utilities reusable.

---

## Component Structure

```
lib/
├── mala_japs/          # Mala/jap counter feature (main screen)
├── family_members/     # Family list, member detail, tree views
├── famity_tree/        # Tree visualization pages + string tools
│   ├── pages/          # Add/edit/create/update/view tree nodes
│   └── tools/          # string_extension.dart utility
├── settings/           # App settings screen
├── data_model/         # Pure data classes + ChangeNotifier models
├── common/             # Shared services (DB, prefs, drive, file I/O)
├── l10n/               # Localization ARB files + generated classes
├── resources/          # Bundled JSON family data assets
├── generated/          # Build-generated files (server_client_id.dart)
└── main.dart           # App entry point, Provider setup
```

---

## Design Patterns Detected

| Pattern | Usage | Location |
|---------|-------|----------|
| **Provider / ChangeNotifier** | App-wide state (locale, settings) | `lib/data_model/locale_model.dart:6`, `lib/data_model/settings_model.dart:4` |
| **Singleton** | DB and shared pref access | `lib/common/sqlite_db_provider.dart:8` |
| **State split** | StatefulWidget state in separate `_state.dart` file | `lib/mala_japs/mala_jap_counter_page_state.dart` |
| **Factory static method** | Async initialization of models | `lib/data_model/settings_model.dart:26` |
| **JSON serialization** | `toJson`/`fromJson` on model classes | `lib/data_model/mala.dart:18` |

### Primary Pattern: Provider + ChangeNotifier

```dart
// Source: lib/data_model/settings_model.dart:26-43
static Future<SettingsModel> getInstance() async {
  _prefs = await SharedPreferences.getInstance();
  final model = SettingsModel();
  model._themeMode = _themeModeFromString(_prefs.getString(_keyThemeMode));
  return model;
}

set themeMode(ThemeMode mode) {
  _themeMode = mode;
  _prefs.setString(_keyThemeMode, _stringFromThemeMode(mode));
  notifyListeners(); // triggers UI rebuild
}
```

**When to use**: Any app-wide state that multiple widgets need to read or react to.

---

## Layer Responsibilities

| Component | Responsibility | Depends On |
|-----------|----------------|------------|
| Feature folders (`mala_japs/`, etc.) | UI widgets, user interaction, feature state | `data_model/`, `common/` |
| `data_model/` | Plain data classes, ChangeNotifier models, serialization | `common/` (for SharedPreferences) |
| `common/` | DB access, file I/O, Google Drive, snackbars | `data_model/` for type shapes |
| `l10n/` | Localization strings | Nothing (generated) |
| `resources/` | Bundled JSON assets | Nothing |

---

## Dependency Rules

```
Feature Pages ──► data_model/ ──► common/
     │                              │
     └──────────────────────────────┘
                  (direct import for services)
```

| Rule | Enforced By |
|------|-------------|
| `common/` services are accessed directly (no DI container) | Convention |
| `data_model/` classes have no Flutter widget imports | Convention |
| Singleton DB instance via `DBProvider.db` | Pattern in `sqlite_db_provider.dart:8` |

**Violations to avoid:**
- Do not import feature-specific pages from `common/` or `data_model/`
- Do not put UI widget code in `data_model/` classes

---

## Data Flow — Typical Mala Save

```
User tap (Widget)
  → State class (_MyHomePageState)
  → SharedPref.saveList(key, malas)        // persist locally
  → GoogleDrive.uploadFileToGoogleDrive()  // optional backup
```

**Example flow (count a mala)**:
1. Button tap in `mala_jap_counter_page_state.dart`
2. Local `malas` list updated in state
3. `SharedPref.saveList` persists to `SharedPreferences`
4. `setState()` triggers widget rebuild

---

## Adding New Features

### To add a new screen/feature:
1. Create feature folder: `lib/[feature_name]/`
2. Add widget file: `[feature_name]_page.dart`
3. If stateful and complex: split state to `[feature_name]_page_state.dart`
4. Add data model in `lib/data_model/[model].dart` if needed
5. Wire navigation from parent widget (typically `mala_jap_counter_page.dart` menu)

### To add a new persistent setting:
1. Add `static const _key[Name]` key to `lib/data_model/settings_model.dart`
2. Add private field + getter + setter with `notifyListeners()`
3. Load from prefs in `getInstance()`

### To add a new SQLite operation:
1. Add method to `lib/common/sqlite_db_provider.dart`
2. Follow `rawQuery`/`rawInsert`/`rawDelete` pattern already used

---

## Configuration

| Config Type | Location | Accessed Via |
|-------------|----------|--------------|
| App version | `pubspec.yaml` | Build system |
| Google OAuth client ID | `lib/generated/server_client_id.dart` | `kServerClientId` constant |
| SharedPreferences keys | `lib/data_model/settings_model.dart` | `_key*` constants |
| Bundled JSON data | `lib/resources/*.json` | `rootBundle` / `json_file_handler.dart` |

---

## Boundaries Summary

| DO | DON'T |
|----|-------|
| Add features as new folders under `lib/` | Put feature logic in `common/` |
| Use `ChangeNotifier` + Provider for app-wide state | Use `StatefulWidget` setState for cross-widget state |
| Use `SharedPref` for key-value data, `DBProvider` for relational data | Mix storage strategies for same data type |
| Keep `data_model/` classes framework-agnostic (no widgets) | Import widgets into data model classes |

---

## Quick Reference

| Need | Location |
|------|----------|
| App entry point | `lib/main.dart` |
| Main screen | `lib/mala_japs/mala_jap_counter_page.dart` |
| App settings | `lib/settings/settings_page.dart` |
| Database access | `lib/common/sqlite_db_provider.dart` |
| Key-value storage | `lib/common/shared_pref.dart` |
| Google Drive | `lib/common/google_drive.dart` |
| Localization strings | `lib/l10n/app_en.arb`, `lib/l10n/app_hi.arb` |
| Shared utilities | `lib/common/` |
