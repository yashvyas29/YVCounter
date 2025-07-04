import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../data_model/treemember.dart';

class DBProvider {
  DBProvider._();

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

    var res = await db.rawQuery('''
    SELECT * FROM sqlite_master WHERE name ='$table' and type='table';
    ''');

    return res.isNotEmpty;
  }

  Future<int> getRowCount(String table) async {
    final db = await database;

    var res = await db.rawQuery('''
      SELECT COUNT(*) from '$table';
      ''');

    return res.length;
  }

  Future<bool> checkIfValueExists(
    String tableName,
    String columnName,
    String columnValue,
  ) async {
    final db = await database;

    var res = await db.rawQuery('''
    SELECT * FROM '$tableName' WHERE $columnName = '$columnValue';
    ''');

    // debugPrint(res.toString());
    return res.isNotEmpty;
  }

  Future<void> createTable(String familyName) async {
    final db = await database;

    db
      ..execute('''
   CREATE TABLE IF NOT EXISTS '$familyName' (
   id INTEGER PRIMARY KEY AUTOINCREMENT,
   name TEXT,
   c INTEGER);
    ''')
      ..rawInsert(
        '''
     REPLACE INTO '$familyName' (id, name, c)
      VALUES (?, ?, ?);
     ''',
        [1, familyName, null],
      );
  }

  Future<List<Map>> cleanTable(String table) async {
    final db = await database;
    var res = await db.rawQuery('''
    delete from '$table';
    ''');
    return res;
  }

  Future<List<Map>> deleteTable(String table) async {
    final db = await database;
    var res = await db.rawQuery('''
    drop table if exists '$table';
    ''');
    return res;
  }

  Future<void> renameTable(String oldName, String newName) async {
    final db = await database;
    await db.rawQuery('''
    ALTER TABLE '$oldName' RENAME TO '$newName';
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

    var res = await db.rawInsert(
      '''
    INSERT INTO '$table' (id, name, c)
    VALUES (?, ?, ?);
    ''',
      [treeMember.id, treeMember.name, treeMember.c],
    );

    //print(res);
    return res;
  }

  Future<void> updateMember(String table, TreeMember treeMember) async {
    final db = await database;
    await db.rawInsert(
      '''
     REPLACE INTO '$table' (id, name, c)
      VALUES (?, ?, ?);
     ''',
      [treeMember.id, treeMember.name, treeMember.c],
    );
  }

  Future<int> removeMember(TreeMember treeMember, String table) async {
    final db = await database;

    var res = await db.rawDelete(
      '''
     DELETE FROM '$table' WHERE id = ?;
     ''',
      [treeMember.id],
    );

    //print(res);
    return res;
  }

  Future<List<Map>> getMembers(String table) async {
    final db = await database;
    var res = await db.rawQuery('''
    SELECT * FROM '$table';
    ''');
    //print(res);
    if (res.isEmpty || res.isEmpty) {
      return Future.error("No data found.");
    }
    return res;
  }
}
