import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();
  static Database? _database;

  Future<Database> get database async {
    _database ??= await openDatabase(
      join(await getDatabasesPath(), 'family.db'),
      version: 1,
    );
    return _database!;
  }

  Future<bool> checkIfTableExists(String table) async {
    final db = await database;

    var res = await db.rawQuery('''
    
    SELECT * FROM sqlite_master WHERE name ='$table' and type='table';
    
    ''');

    if (res.length == 1) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> checkIfNameExists(String table, String name) async {
    final db = await database;

    var res = await db.rawQuery('''
    
    SELECT * FROM $table WHERE name ='$name';
    
    ''');

    if (res.length == 1) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> createNewTable(String familyName) async {
    final db = await database;

    String name = familyName;

    db
      ..execute('''
   CREATE TABLE IF NOT EXISTS '$name' (
   id INTEGER PRIMARY KEY AUTOINCREMENT,
   name TEXT,
   c INTEGER);
    ''')
      ..rawInsert('''
     REPLACE INTO '$name' (id, name, c)
      VALUES (?, ?, ?);
     ''', [1, name, null]);
  }

  Future<List<Map>> getFamilies() async {
    final db = await database;
    var res = await db.rawQuery('''
    SELECT name FROM sqlite_master WHERE type ='table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'android_%';
    ''');
    return res;
  }

  Future<List<Map>> cleanTable(String column) async {
    final db = await database;
    var res = await db.rawQuery('''
    delete from $column;
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
}
