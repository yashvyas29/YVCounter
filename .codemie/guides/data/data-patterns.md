# Data Patterns Guide

**Project**: YVCounter
**Storage**: SQLite (`sqflite`) + SharedPreferences + JSON files
**Data Access**: Raw SQL (via `sqflite`) + `shared_preferences` SDK + `dart:convert`
**Models Location**: `lib/data_model/`, `lib/common/`

---

## Storage Strategy

| Data Type | Storage | Access Class |
|-----------|---------|--------------|
| Family tree members | SQLite (`family.db`) | `lib/common/sqlite_db_provider.dart` |
| Mala/jap history | SharedPreferences (JSON list) | `lib/common/shared_pref.dart` |
| App settings (theme, labels, colors) | SharedPreferences | `lib/data_model/settings_model.dart` |
| App language | SharedPreferences | `lib/data_model/locale_model.dart` |
| Bundled family data | JSON asset files | `lib/common/json_file_handler.dart` |

---

## SQLite: DBProvider Singleton

```dart
// Source: lib/common/sqlite_db_provider.dart:7-21
class DBProvider {
  DBProvider._();
  static final DBProvider db = DBProvider._();
  static const dbName = 'family.db';
  static Database? _database;

  Future<Database> get database async {
    _database ??= await openDatabase(await getDatabasePath(), version: 1);
    return _database!;
  }
}
```

**Access pattern**: Always use `DBProvider.db.methodName()` — never instantiate directly.

### CRUD Operations

| Operation | Method | Source |
|-----------|--------|--------|
| Insert member | `insertMember(treeMember, table)` | `sqlite_db_provider.dart:110` |
| Update member | `updateMember(table, treeMember)` | `sqlite_db_provider.dart:125` |
| Delete member | `removeMember(treeMember, table)` | `sqlite_db_provider.dart:136` |
| Get all members | `getMembers(table)` | `sqlite_db_provider.dart:150` |
| Get families | `getFamilies()` | `sqlite_db_provider.dart:102` |
| Create table | `createTable(familyName)` | `sqlite_db_provider.dart:60` |

### Table Schema

```sql
-- Each family is its own table, named by familyName
CREATE TABLE IF NOT EXISTS 'familyName' (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT,
  c INTEGER   -- parent id reference
);
```

Tables are dynamic (one per family). Family names are stored as table names — query via `sqlite_master`.

### Raw Query Pattern

```dart
// Source: lib/common/sqlite_db_provider.dart:44-58
Future<bool> checkIfValueExists(
  String tableName, String columnName, String columnValue) async {
  final db = await database;
  var res = await db.rawQuery('''
    SELECT * FROM '$tableName' WHERE $columnName = '$columnValue';
  ''');
  return res.isNotEmpty;
}
```

All queries use `rawQuery`/`rawInsert`/`rawDelete` — no ORM.

---

## SharedPreferences: Key-Value Storage

### Mala List Pattern

```dart
// Source: lib/common/shared_pref.dart:17-26
Future<List<Mala>> readList(String key) async {
  final prefs = await SharedPreferences.getInstance();
  final list = prefs.getStringList(key);
  return list == null
      ? []
      : list.map((value) => Mala.fromJson(json.decode(value))).toList();
}

Future<void> saveList(String key, List<Mala> malas) async {
  final list = malas.map((mala) => json.encode(mala.toJson())).toList();
  final prefs = await SharedPreferences.getInstance();
  prefs.setStringList(key, list);
}
```

**Pattern**: Serialize model to JSON string → store as `StringList`. Deserialize on read.

### Settings Pattern (ChangeNotifier)

```dart
// Source: lib/data_model/settings_model.dart:66-72
set themeMode(ThemeMode mode) {
  _themeMode = mode;
  _prefs.setString(_keyThemeMode, _stringFromThemeMode(mode));
  notifyListeners();
}
```

**Pattern**: Setting a value persists immediately + notifies listeners. No explicit save call needed.

---

## Data Model: JSON Serialization

```dart
// Source: lib/data_model/mala.dart:18-30
Mala.fromJson(Map<String, dynamic> json)
  : date = DateTime.parse(json['date']),
    count = json['count'],
    japs = json['japs'];

Map<String, dynamic> toJson() => {
  'date': date.toIso8601String(),
  'count': count,
  'japs': japs,
};
```

**Convention**: All serializable models implement `fromJson` constructor + `toJson()` method. Dates use ISO 8601 strings.

---

## Bundled JSON Assets

Families (e.g., Vyas, Kadvawat) ship as JSON assets in `lib/resources/`.
Both English and Hindi variants exist (e.g., `vyas_family.json` + `vyas_family_hi.json`).
Loaded via `json_file_handler.dart` + `rootBundle`.

---

## Adding New Persistent Data

### New key-value setting:
1. Add `static const _key[Name] = '[key_string]'` in `settings_model.dart`
2. Add private field + getter
3. Add setter with `_prefs.set[Type](_key, value)` + `notifyListeners()`
4. Load in `getInstance()` from prefs

### New SQLite table/entity:
1. Add `createTable(name)` call when feature initializes
2. Add CRUD methods to `DBProvider` following `rawQuery`/`rawInsert` pattern
3. Define a corresponding data class in `lib/data_model/`

### New list stored in SharedPreferences:
1. Define model class with `fromJson`/`toJson`
2. Use `SharedPref.readList`/`saveList` with a unique key constant

---

## Conventions Summary

| DO | DON'T |
|----|-------|
| Use `DBProvider.db` singleton | Create new `DBProvider` instances |
| Use parameterized queries with `?` placeholders | String-interpolate user data into SQL |
| Serialize dates as ISO 8601 | Store `DateTime` directly in prefs |
| Call `notifyListeners()` in SettingsModel setters | Forget to notify after mutating model state |
| One table per family in SQLite | Mix family data into a single table |

---

## Quick Reference

| Need | Location |
|------|----------|
| SQLite provider | `lib/common/sqlite_db_provider.dart` |
| Mala list persistence | `lib/common/shared_pref.dart` |
| Settings persistence | `lib/data_model/settings_model.dart` |
| Family tree data model | `lib/data_model/treemember.dart` |
| Mala data model | `lib/data_model/mala.dart` |
| JSON asset loading | `lib/common/json_file_handler.dart` |
