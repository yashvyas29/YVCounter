import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../data_model/treemember.dart';

class DBProvider {
  DBProvider._();

  /// Escapes a table/value name for safe embedding in raw SQL by doubling
  /// any single-quote characters (standard SQLite escaping).
  static String _escape(String name) => name.replaceAll("'", "''");

  static final DBProvider db = DBProvider._();
  static const dbName = 'family.db';
  static Database? _database;

  Future<String> getDatabasePath() async {
    final path = await getDatabasesPath();
    debugPrint(path);
    return join(path, dbName);
  }

  Future<Database> get database async {
    _database ??= await openDatabase(await getDatabasePath(), version: 1);
    return _database!;
  }

  Future<bool> checkIfTableExists(String table) async {
    final db = await database;
    final escaped = _escape(table);
    var res = await db.rawQuery('''
    SELECT * FROM sqlite_master WHERE name ='$escaped' and type='table';
    ''');
    return res.isNotEmpty;
  }

  Future<int> getRowCount(String table) async {
    final db = await database;
    final escaped = _escape(table);
    var res = await db.rawQuery('''
      SELECT COUNT(*) from '$escaped';
      ''');
    return res.length;
  }

  Future<bool> checkIfValueExists(
    String tableName,
    String columnName,
    String columnValue,
  ) async {
    final db = await database;
    final escapedTable = _escape(tableName);
    var res = await db.rawQuery(
      '''SELECT * FROM '$escapedTable' WHERE $columnName = ?;''',
      [columnValue],
    );
    return res.isNotEmpty;
  }

  Future<void> createTable(String familyName) async {
    final db = await database;
    final escaped = _escape(familyName);
    db
      ..execute('''
   CREATE TABLE IF NOT EXISTS '$escaped' (
   id INTEGER PRIMARY KEY AUTOINCREMENT,
   name TEXT,
   c INTEGER);
    ''')
      ..rawInsert(
        '''
     REPLACE INTO '$escaped' (id, name, c)
      VALUES (?, ?, ?);
     ''',
        [1, familyName, null],
      );
  }

  Future<List<Map>> cleanTable(String table) async {
    final db = await database;
    final escaped = _escape(table);
    var res = await db.rawQuery('''
    delete from '$escaped';
    ''');
    return res;
  }

  Future<List<Map>> deleteTable(String table) async {
    final db = await database;
    final escaped = _escape(table);
    var res = await db.rawQuery('''
    drop table if exists '$escaped';
    ''');
    return res;
  }

  Future<void> renameTable(String oldName, String newName) async {
    final db = await database;
    final escapedOld = _escape(oldName);
    final escapedNew = _escape(newName);
    await db.rawQuery('''
    ALTER TABLE '$escapedOld' RENAME TO '$escapedNew';
    ''');
  }

  Future<List<Map>> getFamilies() async {
    final db = await database;
    var res = await db.rawQuery('''
    SELECT name FROM sqlite_master WHERE type ='table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'android_%';
    ''');
    return res;
  }

  Future<int> insertMember(TreeMember treeMember, String table) async {
    final db = await database;
    final escaped = _escape(table);
    var res = await db.rawInsert(
      '''
    INSERT INTO '$escaped' (id, name, c)
    VALUES (?, ?, ?);
    ''',
      [treeMember.id, treeMember.name, treeMember.c],
    );
    return res;
  }

  Future<void> updateMember(String table, TreeMember treeMember) async {
    final db = await database;
    final escaped = _escape(table);
    await db.rawInsert(
      '''
     REPLACE INTO '$escaped' (id, name, c)
      VALUES (?, ?, ?);
     ''',
      [treeMember.id, treeMember.name, treeMember.c],
    );
  }

  Future<int> removeMember(TreeMember treeMember, String table) async {
    final db = await database;
    final escaped = _escape(table);
    var res = await db.rawDelete(
      '''
     DELETE FROM '$escaped' WHERE id = ?;
     ''',
      [treeMember.id],
    );
    return res;
  }

  Future<List<Map>> getMembers(String table) async {
    final db = await database;
    final escaped = _escape(table);
    var res = await db.rawQuery('''
    SELECT * FROM '$escaped';
    ''');
    if (res.isEmpty) {
      return Future.error("No data found.");
    }
    return res;
  }
}
