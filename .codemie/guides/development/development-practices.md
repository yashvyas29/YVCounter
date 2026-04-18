# Development Practices Guide

**Project**: YVCounter
**Language**: Dart 3.11.1 | **Framework**: Flutter 3.41.4
**Linter**: flutter_lints | **Formatter**: dart format (built-in)

---

## Code Style

### Naming Conventions

| Element | Convention | Example |
|---------|------------|---------|
| Files | `snake_case` | `mala_jap_counter_page.dart` |
| Classes | `PascalCase` | `DBProvider`, `SettingsModel` |
| Methods/functions | `camelCase` | `insertMember`, `getDatabasePath` |
| Variables | `camelCase` | `_primaryLabel`, `familyCardColor` |
| Constants | `camelCase` (Dart convention) | `japsPerMala`, `dbName` |
| Private members | `_prefix` | `_database`, `_themeMode` |
| Extensions | `PascalCase` suffix `Extension` | `CapExtension` |

### Import Order

```dart
// 1. dart: core libs
import 'dart:convert';
import 'dart:io';

// 2. package: flutter SDK
import 'package:flutter/material.dart';

// 3. package: pub dependencies
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

// 4. package:yv_counter/ local imports
import 'package:yv_counter/data_model/mala.dart';
import 'package:yv_counter/common/shared_pref.dart';
```

---

## Code Quality

### Commands

| Action | Command |
|--------|---------|
| Analyze (lint) | `flutter analyze` |
| Format | `dart format lib/` |
| Run tests | `flutter test` |
| Get dependencies | `flutter pub get` |
| Upgrade deps | `flutter pub upgrade` |
| Build Android APK | `flutter build apk` |
| Build iOS | `flutter build ios` |
| Run app | `flutter run` |

### Configuration Files

| Tool | Config File |
|------|-------------|
| Linter | `analysis_options.yaml` (extends `flutter_lints`) |
| Launcher icons | `flutter_launcher_icons.yaml` |
| Dependencies | `pubspec.yaml` |

### CI

GitHub Actions workflow at `.github/workflows/flutter.yml` — runs `flutter analyze` + `flutter test` on push/PR.

---

## State Management: Provider + ChangeNotifier

The app uses the `provider` package. App-wide state lives in `ChangeNotifier` models initialized before `runApp`.

```dart
// Source: lib/main.dart:13-21
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final localeModel = await LocaleModel.getInstance();
  final settingsModel = await SettingsModel.getInstance();
  runApp(MyApp(localeModel: localeModel, settingsModel: settingsModel));
}
```

```dart
// Source: lib/main.dart:36-54 — inject via MultiProvider, consume with Consumer2
return MultiProvider(
  providers: [
    ChangeNotifierProvider<LocaleModel>.value(value: localeModel),
    ChangeNotifierProvider<SettingsModel>.value(value: settingsModel),
  ],
  child: Consumer2<LocaleModel, SettingsModel>(
    builder: (context, localeModel, settingsModel, child) => MaterialApp(...),
  ),
);
```

**Rules:**
- Add new app-wide state as a `ChangeNotifier` in `lib/data_model/`
- Use `static Future<T> getInstance()` for async initialization before `runApp`
- Read in widgets via `context.watch<T>()` or `Consumer<T>`
- Call `notifyListeners()` in every setter that mutates state

---

## Widget State Split Pattern

For complex `StatefulWidget` screens, the state class lives in a separate `_state.dart` file using Dart `part`/`part of`.

```dart
// In mala_jap_counter_page.dart:
part 'mala_jap_counter_page_state.dart';

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
  // Non-state helper methods can live on the widget class itself
}
```

```dart
// In mala_jap_counter_page_state.dart:
part of 'mala_jap_counter_page.dart';

class _MyHomePageState extends State<MyHomePage> {
  // All mutable state and lifecycle methods here
}
```

**When to split**: When state class exceeds ~100 lines or has many helper methods.

---

## Localization (l10n)

App supports English (`en`) and Hindi (`hi`). Strings are in ARB files.

```
lib/l10n/
├── app_en.arb           # English strings
├── app_hi.arb           # Hindi strings
└── app_localizations.dart  # Generated, do not edit
```

**Adding a new string:**
1. Add key + value to `lib/l10n/app_en.arb`
2. Add translated value to `lib/l10n/app_hi.arb`
3. Run `flutter gen-l10n` (or `flutter pub get` with `generate: true`)
4. Use: `AppLocalizations.of(context).yourKey`

**Language switching**: Via `LocaleModel.set(Locale locale)` — persisted to SharedPreferences.

---

## Async Patterns

**Style**: `async`/`await` throughout. `Future.error(message)` for error propagation.

```dart
// Source: lib/common/sqlite_db_provider.dart:20-22
Future<Database> get database async {
  _database ??= await openDatabase(await getDatabasePath(), version: 1);
  return _database!;
}
```

**Error propagation**: Use `return Future.error("message")` in service methods; catch in UI:

```dart
// Caller pattern (in state/widget):
try {
  final result = await SomeService.doThing();
  // handle success
} catch (error) {
  SnackbarDialog.show(context, error.toString());
}
```

---

## Extension Methods

Utility extensions live in `lib/famity_tree/tools/string_extension.dart`:

```dart
// Source: lib/famity_tree/tools/string_extension.dart
extension CapExtension on String {
  String get inCaps => '${this[0].toUpperCase()}${substring(1)}';
  String get capitalizeFirstofEach =>
      split(" ").map((str) => str.inCaps).join(" ");
}
```

Add new string utilities here rather than standalone functions.

---

## Logging

Uses `debugPrint` (Flutter's rate-limited print) throughout:

```dart
debugPrint("signIn error: $error");
debugPrint("$fileName downloaded.");
```

**Rules:**
- Use `debugPrint` (not `print`) — it's stripped in release builds
- Include context in the message (method name, relevant ID)
- No sensitive data (tokens, passwords) in debug output

---

## Adding New Dependencies

```bash
# Add to pubspec.yaml dependencies section, then:
flutter pub get

# Check for outdated packages:
flutter pub outdated
```

Always commit `pubspec.lock` after dependency changes.

---

## Don't Do

| Avoid | Instead | Why |
|-------|---------|-----|
| `print(...)` | `debugPrint(...)` | `print` isn't stripped in release |
| Direct `SharedPreferences.getInstance()` in widgets | Use `SettingsModel`/`LocaleModel` via Provider | Keeps state centralized |
| New DBProvider instances | Use `DBProvider.db` singleton | Avoids multiple DB connections |
| Hardcoded strings in widgets | Add to ARB l10n files | Supports localization |
| State mutation without `notifyListeners()` | Always call after mutation | UI won't rebuild |

---

## Quick Reference

| Need | Location |
|------|----------|
| Linter config | `analysis_options.yaml` |
| App state models | `lib/data_model/` |
| Shared utilities | `lib/common/` |
| String extensions | `lib/famity_tree/tools/string_extension.dart` |
| Localization strings | `lib/l10n/app_en.arb`, `lib/l10n/app_hi.arb` |
| CI config | `.github/workflows/flutter.yml` |
