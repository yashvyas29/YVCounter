import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:yv_counter/data_model/mala.dart';

part 'app_database.g.dart';

/// Stores one mala-count record per calendar day.
/// [date] (ISO-8601 date string, e.g. "2024-01-15") acts as the primary key
/// because at most one record per day is meaningful.
class MalaHistories extends Table {
  TextColumn get date => text()();
  IntColumn get count => integer()();
  IntColumn get japs => integer()();

  @override
  Set<Column> get primaryKey => {date};
}

/// Stores family names.  Replaces the old "one SQLite table per family" design.
class Families extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
}

/// Stores family-tree JSON (nodes + edges) per family per language.
/// [familyId] references [Families.id]; [languageCode] is "en" or "hi".
/// The pair (familyId, languageCode) must be unique.
@TableIndex(
  name: 'idx_family_tree_data_family_lang',
  columns: {#familyId, #languageCode},
  unique: true,
)
class FamilyTreeData extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get familyId =>
      integer().references(Families, #id, onDelete: KeyAction.cascade)();
  TextColumn get languageCode => text().withDefault(const Constant('en'))();
  TextColumn get jsonData => text()();
}

@DriftDatabase(tables: [MalaHistories, Families, FamilyTreeData])
class AppDatabase extends _$AppDatabase {
  AppDatabase._() : super(_openDatabase());

  static final AppDatabase instance = AppDatabase._();

  static QueryExecutor _openDatabase() => driftDatabase(name: 'app_database');

  @override
  int get schemaVersion => 1;

  // ── Mala history ────────────────────────────────────────────────────────────

  Future<List<Mala>> getAllMalas() async {
    final rows = await (select(
      malaHistories,
    )..orderBy([(t) => OrderingTerm.desc(t.date)])).get();
    return rows
        .map((r) => Mala(DateTime.parse(r.date), r.count, r.japs))
        .toList();
  }

  Future<void> upsertMala(Mala mala) =>
      into(malaHistories).insertOnConflictUpdate(
        MalaHistoriesCompanion(
          date: Value(mala.date.toIso8601String().substring(0, 10)),
          count: Value(mala.count),
          japs: Value(mala.japs),
        ),
      );

  Future<void> deleteMalaByDate(DateTime date) => (delete(
    malaHistories,
  )..where((t) => t.date.equals(date.toIso8601String().substring(0, 10)))).go();

  // ── Families ─────────────────────────────────────────────────────────────────

  Future<List<Family>> getAllFamilies() => select(families).get();

  Future<Family?> getFamilyByName(String name) =>
      (select(families)..where((t) => t.name.equals(name))).getSingleOrNull();

  Future<int> insertFamilyByName(String name) => into(
    families,
  ).insert(FamiliesCompanion(name: Value(name)), onConflict: DoNothing());

  Future<void> deleteFamilyById(int id) =>
      (delete(families)..where((t) => t.id.equals(id))).go();

  Future<void> updateFamilyName(int id, String newName) =>
      (update(families)..where((t) => t.id.equals(id))).write(
        FamiliesCompanion(name: Value(newName)),
      );

  // ── Family tree JSON ──────────────────────────────────────────────────────────

  Future<String?> getFamilyTreeJson(
    int familyId, {
    String languageCode = 'en',
  }) async {
    final row =
        await (select(familyTreeData)..where(
              (t) =>
                  t.familyId.equals(familyId) &
                  t.languageCode.equals(languageCode),
            ))
            .getSingleOrNull();
    return row?.jsonData;
  }

  Future<void> saveFamilyTreeJson(
    int familyId,
    String jsonData, {
    String languageCode = 'en',
  }) {
    final companion = FamilyTreeDataCompanion(
      familyId: Value(familyId),
      languageCode: Value(languageCode),
      jsonData: Value(jsonData),
    );
    return into(familyTreeData).insert(
      companion,
      onConflict: DoUpdate(
        (_) => FamilyTreeDataCompanion.custom(
          jsonData: Variable(jsonData),
        ),
        target: [familyTreeData.familyId, familyTreeData.languageCode],
      ),
    );
  }

  Future<void> deleteFamilyTreeData(int familyId) =>
      (delete(familyTreeData)..where((t) => t.familyId.equals(familyId))).go();
}
