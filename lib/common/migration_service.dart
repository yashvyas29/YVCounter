import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:yv_counter/common/app_database.dart';
import 'package:yv_counter/common/json_file_handler.dart';
import 'package:yv_counter/data_model/mala.dart';

/// Checks whether the one-time migration from SharedPreferences + sqflite +
/// JSON files to the Drift database has already been completed, and runs it
/// if not.
///
/// Safe to call on every app start — it is a no-op after the first run.
class MigrationService {
  static const _migrationDoneKey = 'drift_migration_v1_done';

  static Future<void> migrateIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_migrationDoneKey) == true) return;

    debugPrint('MigrationService: starting one-time migration to Drift.');

    try {
      await _migrateMalaHistory(prefs);
      await _migrateFamiliesAndTrees();
      await prefs.setBool(_migrationDoneKey, true);
      debugPrint('MigrationService: migration complete.');
    } catch (e) {
      debugPrint('MigrationService: migration failed — $e');
      // Do NOT set the flag so we retry next launch.
    }
  }

  // ── Mala history ─────────────────────────────────────────────────────────────

  static Future<void> _migrateMalaHistory(SharedPreferences prefs) async {
    final list = prefs.getStringList(Mala.key);
    if (list == null || list.isEmpty) {
      debugPrint('MigrationService: no mala history to migrate.');
      return;
    }

    final db = AppDatabase.instance;
    for (final item in list) {
      try {
        final mala = Mala.fromJson(json.decode(item));
        await db.upsertMala(mala);
      } catch (e) {
        debugPrint('MigrationService: skipping malformed mala record — $e');
      }
    }
    await prefs.remove(Mala.key);
    debugPrint('MigrationService: migrated ${list.length} mala records.');
  }

  // ── Families + family tree JSON ───────────────────────────────────────────────

  static Future<void> _migrateFamiliesAndTrees() async {
    final db = AppDatabase.instance;
    const jsonHandler = JsonFileHandler();

    // Read family names stored as table names in the old family.db.
    final oldFamilyNames = await _readOldFamilyNames();
    debugPrint(
      'MigrationService: found ${oldFamilyNames.length} families in old DB.',
    );

    for (final name in oldFamilyNames) {
      int familyId = await db.insertFamilyByName(name);
      if (familyId == 0) {
        // DoNothing conflict — family already exists, fetch its id.
        final existing = await db.getFamilyByName(name);
        if (existing == null) continue;
        familyId = existing.id;
      }

      // Migrate English tree JSON.
      await _migrateTreeJson(
        jsonHandler: jsonHandler,
        db: db,
        familyName: name,
        familyId: familyId,
        languageCode: 'en',
      );

      // Migrate Hindi tree JSON (if available).
      await _migrateTreeJson(
        jsonHandler: jsonHandler,
        db: db,
        familyName: name,
        familyId: familyId,
        languageCode: 'hi',
      );
    }
  }

  static Future<void> _migrateTreeJson({
    required JsonFileHandler jsonHandler,
    required AppDatabase db,
    required String familyName,
    required int familyId,
    required String languageCode,
  }) async {
    final baseName = jsonHandler.getFamilyFileName(familyName);
    final fileName = languageCode == 'hi' ? '${baseName}_hi' : baseName;

    Map<String, dynamic> data = await jsonHandler.readJson(fileName);
    if (data.isEmpty) {
      // No local file — try the bundled asset.
      try {
        data = await jsonHandler.readJsonFromBundle(fileName);
      } catch (_) {
        // Bundle variant absent — nothing to migrate.
      }
    }

    if (data.isEmpty) return;

    await db.saveFamilyTreeJson(
      familyId,
      jsonEncode(data),
      languageCode: languageCode,
    );
    debugPrint(
      'MigrationService: saved tree JSON for "$familyName" ($languageCode).',
    );
  }

  /// Opens the old sqflite `family.db` and reads all user-created table names
  /// (these were family names stored as SQLite table names).
  static Future<List<String>> _readOldFamilyNames() async {
    try {
      final dbsPath = await getDatabasesPath();
      final path = p.join(dbsPath, 'family.db');
      if (!await File(path).exists()) return [];

      final oldDb = await openDatabase(path, readOnly: true);
      final rows = await oldDb.rawQuery(
        "SELECT name FROM sqlite_master "
        "WHERE type='table' "
        "AND name NOT LIKE 'sqlite_%' "
        "AND name NOT LIKE 'android_%';",
      );
      await oldDb.close();
      return rows.map((r) => r['name'] as String).toList();
    } catch (e) {
      debugPrint('MigrationService: could not read old family.db — $e');
      return [];
    }
  }
}
