// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $MalaHistoriesTable extends MalaHistories
    with TableInfo<$MalaHistoriesTable, MalaHistory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MalaHistoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countMeta = const VerificationMeta('count');
  @override
  late final GeneratedColumn<int> count = GeneratedColumn<int>(
    'count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _japsMeta = const VerificationMeta('japs');
  @override
  late final GeneratedColumn<int> japs = GeneratedColumn<int>(
    'japs',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [date, count, japs];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mala_histories';
  @override
  VerificationContext validateIntegrity(
    Insertable<MalaHistory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('count')) {
      context.handle(
        _countMeta,
        count.isAcceptableOrUnknown(data['count']!, _countMeta),
      );
    } else if (isInserting) {
      context.missing(_countMeta);
    }
    if (data.containsKey('japs')) {
      context.handle(
        _japsMeta,
        japs.isAcceptableOrUnknown(data['japs']!, _japsMeta),
      );
    } else if (isInserting) {
      context.missing(_japsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {date};
  @override
  MalaHistory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MalaHistory(
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      count: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}count'],
      )!,
      japs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}japs'],
      )!,
    );
  }

  @override
  $MalaHistoriesTable createAlias(String alias) {
    return $MalaHistoriesTable(attachedDatabase, alias);
  }
}

class MalaHistory extends DataClass implements Insertable<MalaHistory> {
  final String date;
  final int count;
  final int japs;
  const MalaHistory({
    required this.date,
    required this.count,
    required this.japs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date'] = Variable<String>(date);
    map['count'] = Variable<int>(count);
    map['japs'] = Variable<int>(japs);
    return map;
  }

  MalaHistoriesCompanion toCompanion(bool nullToAbsent) {
    return MalaHistoriesCompanion(
      date: Value(date),
      count: Value(count),
      japs: Value(japs),
    );
  }

  factory MalaHistory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MalaHistory(
      date: serializer.fromJson<String>(json['date']),
      count: serializer.fromJson<int>(json['count']),
      japs: serializer.fromJson<int>(json['japs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'date': serializer.toJson<String>(date),
      'count': serializer.toJson<int>(count),
      'japs': serializer.toJson<int>(japs),
    };
  }

  MalaHistory copyWith({String? date, int? count, int? japs}) => MalaHistory(
    date: date ?? this.date,
    count: count ?? this.count,
    japs: japs ?? this.japs,
  );
  MalaHistory copyWithCompanion(MalaHistoriesCompanion data) {
    return MalaHistory(
      date: data.date.present ? data.date.value : this.date,
      count: data.count.present ? data.count.value : this.count,
      japs: data.japs.present ? data.japs.value : this.japs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MalaHistory(')
          ..write('date: $date, ')
          ..write('count: $count, ')
          ..write('japs: $japs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(date, count, japs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MalaHistory &&
          other.date == this.date &&
          other.count == this.count &&
          other.japs == this.japs);
}

class MalaHistoriesCompanion extends UpdateCompanion<MalaHistory> {
  final Value<String> date;
  final Value<int> count;
  final Value<int> japs;
  final Value<int> rowid;
  const MalaHistoriesCompanion({
    this.date = const Value.absent(),
    this.count = const Value.absent(),
    this.japs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MalaHistoriesCompanion.insert({
    required String date,
    required int count,
    required int japs,
    this.rowid = const Value.absent(),
  }) : date = Value(date),
       count = Value(count),
       japs = Value(japs);
  static Insertable<MalaHistory> custom({
    Expression<String>? date,
    Expression<int>? count,
    Expression<int>? japs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (date != null) 'date': date,
      if (count != null) 'count': count,
      if (japs != null) 'japs': japs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MalaHistoriesCompanion copyWith({
    Value<String>? date,
    Value<int>? count,
    Value<int>? japs,
    Value<int>? rowid,
  }) {
    return MalaHistoriesCompanion(
      date: date ?? this.date,
      count: count ?? this.count,
      japs: japs ?? this.japs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (count.present) {
      map['count'] = Variable<int>(count.value);
    }
    if (japs.present) {
      map['japs'] = Variable<int>(japs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MalaHistoriesCompanion(')
          ..write('date: $date, ')
          ..write('count: $count, ')
          ..write('japs: $japs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FamiliesTable extends Families with TableInfo<$FamiliesTable, Family> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FamiliesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'families';
  @override
  VerificationContext validateIntegrity(
    Insertable<Family> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Family map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Family(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $FamiliesTable createAlias(String alias) {
    return $FamiliesTable(attachedDatabase, alias);
  }
}

class Family extends DataClass implements Insertable<Family> {
  final int id;
  final String name;
  const Family({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  FamiliesCompanion toCompanion(bool nullToAbsent) {
    return FamiliesCompanion(id: Value(id), name: Value(name));
  }

  factory Family.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Family(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  Family copyWith({int? id, String? name}) =>
      Family(id: id ?? this.id, name: name ?? this.name);
  Family copyWithCompanion(FamiliesCompanion data) {
    return Family(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Family(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Family && other.id == this.id && other.name == this.name);
}

class FamiliesCompanion extends UpdateCompanion<Family> {
  final Value<int> id;
  final Value<String> name;
  const FamiliesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  FamiliesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<Family> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  FamiliesCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return FamiliesCompanion(id: id ?? this.id, name: name ?? this.name);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FamiliesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $FamilyTreeDataTable extends FamilyTreeData
    with TableInfo<$FamilyTreeDataTable, FamilyTreeDataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FamilyTreeDataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _familyIdMeta = const VerificationMeta(
    'familyId',
  );
  @override
  late final GeneratedColumn<int> familyId = GeneratedColumn<int>(
    'family_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES families (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _languageCodeMeta = const VerificationMeta(
    'languageCode',
  );
  @override
  late final GeneratedColumn<String> languageCode = GeneratedColumn<String>(
    'language_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('en'),
  );
  static const VerificationMeta _jsonDataMeta = const VerificationMeta(
    'jsonData',
  );
  @override
  late final GeneratedColumn<String> jsonData = GeneratedColumn<String>(
    'json_data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, familyId, languageCode, jsonData];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'family_tree_data';
  @override
  VerificationContext validateIntegrity(
    Insertable<FamilyTreeDataData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('family_id')) {
      context.handle(
        _familyIdMeta,
        familyId.isAcceptableOrUnknown(data['family_id']!, _familyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_familyIdMeta);
    }
    if (data.containsKey('language_code')) {
      context.handle(
        _languageCodeMeta,
        languageCode.isAcceptableOrUnknown(
          data['language_code']!,
          _languageCodeMeta,
        ),
      );
    }
    if (data.containsKey('json_data')) {
      context.handle(
        _jsonDataMeta,
        jsonData.isAcceptableOrUnknown(data['json_data']!, _jsonDataMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonDataMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FamilyTreeDataData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FamilyTreeDataData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      familyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}family_id'],
      )!,
      languageCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language_code'],
      )!,
      jsonData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json_data'],
      )!,
    );
  }

  @override
  $FamilyTreeDataTable createAlias(String alias) {
    return $FamilyTreeDataTable(attachedDatabase, alias);
  }
}

class FamilyTreeDataData extends DataClass
    implements Insertable<FamilyTreeDataData> {
  final int id;
  final int familyId;
  final String languageCode;
  final String jsonData;
  const FamilyTreeDataData({
    required this.id,
    required this.familyId,
    required this.languageCode,
    required this.jsonData,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['family_id'] = Variable<int>(familyId);
    map['language_code'] = Variable<String>(languageCode);
    map['json_data'] = Variable<String>(jsonData);
    return map;
  }

  FamilyTreeDataCompanion toCompanion(bool nullToAbsent) {
    return FamilyTreeDataCompanion(
      id: Value(id),
      familyId: Value(familyId),
      languageCode: Value(languageCode),
      jsonData: Value(jsonData),
    );
  }

  factory FamilyTreeDataData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FamilyTreeDataData(
      id: serializer.fromJson<int>(json['id']),
      familyId: serializer.fromJson<int>(json['familyId']),
      languageCode: serializer.fromJson<String>(json['languageCode']),
      jsonData: serializer.fromJson<String>(json['jsonData']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'familyId': serializer.toJson<int>(familyId),
      'languageCode': serializer.toJson<String>(languageCode),
      'jsonData': serializer.toJson<String>(jsonData),
    };
  }

  FamilyTreeDataData copyWith({
    int? id,
    int? familyId,
    String? languageCode,
    String? jsonData,
  }) => FamilyTreeDataData(
    id: id ?? this.id,
    familyId: familyId ?? this.familyId,
    languageCode: languageCode ?? this.languageCode,
    jsonData: jsonData ?? this.jsonData,
  );
  FamilyTreeDataData copyWithCompanion(FamilyTreeDataCompanion data) {
    return FamilyTreeDataData(
      id: data.id.present ? data.id.value : this.id,
      familyId: data.familyId.present ? data.familyId.value : this.familyId,
      languageCode: data.languageCode.present
          ? data.languageCode.value
          : this.languageCode,
      jsonData: data.jsonData.present ? data.jsonData.value : this.jsonData,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FamilyTreeDataData(')
          ..write('id: $id, ')
          ..write('familyId: $familyId, ')
          ..write('languageCode: $languageCode, ')
          ..write('jsonData: $jsonData')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, familyId, languageCode, jsonData);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FamilyTreeDataData &&
          other.id == this.id &&
          other.familyId == this.familyId &&
          other.languageCode == this.languageCode &&
          other.jsonData == this.jsonData);
}

class FamilyTreeDataCompanion extends UpdateCompanion<FamilyTreeDataData> {
  final Value<int> id;
  final Value<int> familyId;
  final Value<String> languageCode;
  final Value<String> jsonData;
  const FamilyTreeDataCompanion({
    this.id = const Value.absent(),
    this.familyId = const Value.absent(),
    this.languageCode = const Value.absent(),
    this.jsonData = const Value.absent(),
  });
  FamilyTreeDataCompanion.insert({
    this.id = const Value.absent(),
    required int familyId,
    this.languageCode = const Value.absent(),
    required String jsonData,
  }) : familyId = Value(familyId),
       jsonData = Value(jsonData);
  static Insertable<FamilyTreeDataData> custom({
    Expression<int>? id,
    Expression<int>? familyId,
    Expression<String>? languageCode,
    Expression<String>? jsonData,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (familyId != null) 'family_id': familyId,
      if (languageCode != null) 'language_code': languageCode,
      if (jsonData != null) 'json_data': jsonData,
    });
  }

  FamilyTreeDataCompanion copyWith({
    Value<int>? id,
    Value<int>? familyId,
    Value<String>? languageCode,
    Value<String>? jsonData,
  }) {
    return FamilyTreeDataCompanion(
      id: id ?? this.id,
      familyId: familyId ?? this.familyId,
      languageCode: languageCode ?? this.languageCode,
      jsonData: jsonData ?? this.jsonData,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (familyId.present) {
      map['family_id'] = Variable<int>(familyId.value);
    }
    if (languageCode.present) {
      map['language_code'] = Variable<String>(languageCode.value);
    }
    if (jsonData.present) {
      map['json_data'] = Variable<String>(jsonData.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FamilyTreeDataCompanion(')
          ..write('id: $id, ')
          ..write('familyId: $familyId, ')
          ..write('languageCode: $languageCode, ')
          ..write('jsonData: $jsonData')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MalaHistoriesTable malaHistories = $MalaHistoriesTable(this);
  late final $FamiliesTable families = $FamiliesTable(this);
  late final $FamilyTreeDataTable familyTreeData = $FamilyTreeDataTable(this);
  late final Index idxFamilyTreeDataFamilyLang = Index(
    'idx_family_tree_data_family_lang',
    'CREATE UNIQUE INDEX idx_family_tree_data_family_lang ON family_tree_data (family_id, language_code)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    malaHistories,
    families,
    familyTreeData,
    idxFamilyTreeDataFamilyLang,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'families',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('family_tree_data', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$MalaHistoriesTableCreateCompanionBuilder =
    MalaHistoriesCompanion Function({
      required String date,
      required int count,
      required int japs,
      Value<int> rowid,
    });
typedef $$MalaHistoriesTableUpdateCompanionBuilder =
    MalaHistoriesCompanion Function({
      Value<String> date,
      Value<int> count,
      Value<int> japs,
      Value<int> rowid,
    });

class $$MalaHistoriesTableFilterComposer
    extends Composer<_$AppDatabase, $MalaHistoriesTable> {
  $$MalaHistoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get japs => $composableBuilder(
    column: $table.japs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MalaHistoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $MalaHistoriesTable> {
  $$MalaHistoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get japs => $composableBuilder(
    column: $table.japs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MalaHistoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MalaHistoriesTable> {
  $$MalaHistoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get count =>
      $composableBuilder(column: $table.count, builder: (column) => column);

  GeneratedColumn<int> get japs =>
      $composableBuilder(column: $table.japs, builder: (column) => column);
}

class $$MalaHistoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MalaHistoriesTable,
          MalaHistory,
          $$MalaHistoriesTableFilterComposer,
          $$MalaHistoriesTableOrderingComposer,
          $$MalaHistoriesTableAnnotationComposer,
          $$MalaHistoriesTableCreateCompanionBuilder,
          $$MalaHistoriesTableUpdateCompanionBuilder,
          (
            MalaHistory,
            BaseReferences<_$AppDatabase, $MalaHistoriesTable, MalaHistory>,
          ),
          MalaHistory,
          PrefetchHooks Function()
        > {
  $$MalaHistoriesTableTableManager(_$AppDatabase db, $MalaHistoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MalaHistoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MalaHistoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MalaHistoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> date = const Value.absent(),
                Value<int> count = const Value.absent(),
                Value<int> japs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MalaHistoriesCompanion(
                date: date,
                count: count,
                japs: japs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String date,
                required int count,
                required int japs,
                Value<int> rowid = const Value.absent(),
              }) => MalaHistoriesCompanion.insert(
                date: date,
                count: count,
                japs: japs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MalaHistoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MalaHistoriesTable,
      MalaHistory,
      $$MalaHistoriesTableFilterComposer,
      $$MalaHistoriesTableOrderingComposer,
      $$MalaHistoriesTableAnnotationComposer,
      $$MalaHistoriesTableCreateCompanionBuilder,
      $$MalaHistoriesTableUpdateCompanionBuilder,
      (
        MalaHistory,
        BaseReferences<_$AppDatabase, $MalaHistoriesTable, MalaHistory>,
      ),
      MalaHistory,
      PrefetchHooks Function()
    >;
typedef $$FamiliesTableCreateCompanionBuilder =
    FamiliesCompanion Function({Value<int> id, required String name});
typedef $$FamiliesTableUpdateCompanionBuilder =
    FamiliesCompanion Function({Value<int> id, Value<String> name});

final class $$FamiliesTableReferences
    extends BaseReferences<_$AppDatabase, $FamiliesTable, Family> {
  $$FamiliesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$FamilyTreeDataTable, List<FamilyTreeDataData>>
  _familyTreeDataRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.familyTreeData,
    aliasName: $_aliasNameGenerator(db.families.id, db.familyTreeData.familyId),
  );

  $$FamilyTreeDataTableProcessedTableManager get familyTreeDataRefs {
    final manager = $$FamilyTreeDataTableTableManager(
      $_db,
      $_db.familyTreeData,
    ).filter((f) => f.familyId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_familyTreeDataRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FamiliesTableFilterComposer
    extends Composer<_$AppDatabase, $FamiliesTable> {
  $$FamiliesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> familyTreeDataRefs(
    Expression<bool> Function($$FamilyTreeDataTableFilterComposer f) f,
  ) {
    final $$FamilyTreeDataTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.familyTreeData,
      getReferencedColumn: (t) => t.familyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FamilyTreeDataTableFilterComposer(
            $db: $db,
            $table: $db.familyTreeData,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FamiliesTableOrderingComposer
    extends Composer<_$AppDatabase, $FamiliesTable> {
  $$FamiliesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FamiliesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FamiliesTable> {
  $$FamiliesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  Expression<T> familyTreeDataRefs<T extends Object>(
    Expression<T> Function($$FamilyTreeDataTableAnnotationComposer a) f,
  ) {
    final $$FamilyTreeDataTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.familyTreeData,
      getReferencedColumn: (t) => t.familyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FamilyTreeDataTableAnnotationComposer(
            $db: $db,
            $table: $db.familyTreeData,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FamiliesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FamiliesTable,
          Family,
          $$FamiliesTableFilterComposer,
          $$FamiliesTableOrderingComposer,
          $$FamiliesTableAnnotationComposer,
          $$FamiliesTableCreateCompanionBuilder,
          $$FamiliesTableUpdateCompanionBuilder,
          (Family, $$FamiliesTableReferences),
          Family,
          PrefetchHooks Function({bool familyTreeDataRefs})
        > {
  $$FamiliesTableTableManager(_$AppDatabase db, $FamiliesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FamiliesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FamiliesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FamiliesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
              }) => FamiliesCompanion(id: id, name: name),
          createCompanionCallback:
              ({Value<int> id = const Value.absent(), required String name}) =>
                  FamiliesCompanion.insert(id: id, name: name),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FamiliesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({familyTreeDataRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (familyTreeDataRefs) db.familyTreeData,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (familyTreeDataRefs)
                    await $_getPrefetchedData<
                      Family,
                      $FamiliesTable,
                      FamilyTreeDataData
                    >(
                      currentTable: table,
                      referencedTable: $$FamiliesTableReferences
                          ._familyTreeDataRefsTable(db),
                      managerFromTypedResult: (p0) => $$FamiliesTableReferences(
                        db,
                        table,
                        p0,
                      ).familyTreeDataRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.familyId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$FamiliesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FamiliesTable,
      Family,
      $$FamiliesTableFilterComposer,
      $$FamiliesTableOrderingComposer,
      $$FamiliesTableAnnotationComposer,
      $$FamiliesTableCreateCompanionBuilder,
      $$FamiliesTableUpdateCompanionBuilder,
      (Family, $$FamiliesTableReferences),
      Family,
      PrefetchHooks Function({bool familyTreeDataRefs})
    >;
typedef $$FamilyTreeDataTableCreateCompanionBuilder =
    FamilyTreeDataCompanion Function({
      Value<int> id,
      required int familyId,
      Value<String> languageCode,
      required String jsonData,
    });
typedef $$FamilyTreeDataTableUpdateCompanionBuilder =
    FamilyTreeDataCompanion Function({
      Value<int> id,
      Value<int> familyId,
      Value<String> languageCode,
      Value<String> jsonData,
    });

final class $$FamilyTreeDataTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $FamilyTreeDataTable,
          FamilyTreeDataData
        > {
  $$FamilyTreeDataTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $FamiliesTable _familyIdTable(_$AppDatabase db) =>
      db.families.createAlias(
        $_aliasNameGenerator(db.familyTreeData.familyId, db.families.id),
      );

  $$FamiliesTableProcessedTableManager get familyId {
    final $_column = $_itemColumn<int>('family_id')!;

    final manager = $$FamiliesTableTableManager(
      $_db,
      $_db.families,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_familyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FamilyTreeDataTableFilterComposer
    extends Composer<_$AppDatabase, $FamilyTreeDataTable> {
  $$FamilyTreeDataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get languageCode => $composableBuilder(
    column: $table.languageCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jsonData => $composableBuilder(
    column: $table.jsonData,
    builder: (column) => ColumnFilters(column),
  );

  $$FamiliesTableFilterComposer get familyId {
    final $$FamiliesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.families,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FamiliesTableFilterComposer(
            $db: $db,
            $table: $db.families,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FamilyTreeDataTableOrderingComposer
    extends Composer<_$AppDatabase, $FamilyTreeDataTable> {
  $$FamilyTreeDataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get languageCode => $composableBuilder(
    column: $table.languageCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jsonData => $composableBuilder(
    column: $table.jsonData,
    builder: (column) => ColumnOrderings(column),
  );

  $$FamiliesTableOrderingComposer get familyId {
    final $$FamiliesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.families,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FamiliesTableOrderingComposer(
            $db: $db,
            $table: $db.families,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FamilyTreeDataTableAnnotationComposer
    extends Composer<_$AppDatabase, $FamilyTreeDataTable> {
  $$FamilyTreeDataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get languageCode => $composableBuilder(
    column: $table.languageCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get jsonData =>
      $composableBuilder(column: $table.jsonData, builder: (column) => column);

  $$FamiliesTableAnnotationComposer get familyId {
    final $$FamiliesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.families,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FamiliesTableAnnotationComposer(
            $db: $db,
            $table: $db.families,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FamilyTreeDataTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FamilyTreeDataTable,
          FamilyTreeDataData,
          $$FamilyTreeDataTableFilterComposer,
          $$FamilyTreeDataTableOrderingComposer,
          $$FamilyTreeDataTableAnnotationComposer,
          $$FamilyTreeDataTableCreateCompanionBuilder,
          $$FamilyTreeDataTableUpdateCompanionBuilder,
          (FamilyTreeDataData, $$FamilyTreeDataTableReferences),
          FamilyTreeDataData,
          PrefetchHooks Function({bool familyId})
        > {
  $$FamilyTreeDataTableTableManager(
    _$AppDatabase db,
    $FamilyTreeDataTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FamilyTreeDataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FamilyTreeDataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FamilyTreeDataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> familyId = const Value.absent(),
                Value<String> languageCode = const Value.absent(),
                Value<String> jsonData = const Value.absent(),
              }) => FamilyTreeDataCompanion(
                id: id,
                familyId: familyId,
                languageCode: languageCode,
                jsonData: jsonData,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int familyId,
                Value<String> languageCode = const Value.absent(),
                required String jsonData,
              }) => FamilyTreeDataCompanion.insert(
                id: id,
                familyId: familyId,
                languageCode: languageCode,
                jsonData: jsonData,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FamilyTreeDataTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({familyId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (familyId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.familyId,
                                referencedTable: $$FamilyTreeDataTableReferences
                                    ._familyIdTable(db),
                                referencedColumn:
                                    $$FamilyTreeDataTableReferences
                                        ._familyIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$FamilyTreeDataTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FamilyTreeDataTable,
      FamilyTreeDataData,
      $$FamilyTreeDataTableFilterComposer,
      $$FamilyTreeDataTableOrderingComposer,
      $$FamilyTreeDataTableAnnotationComposer,
      $$FamilyTreeDataTableCreateCompanionBuilder,
      $$FamilyTreeDataTableUpdateCompanionBuilder,
      (FamilyTreeDataData, $$FamilyTreeDataTableReferences),
      FamilyTreeDataData,
      PrefetchHooks Function({bool familyId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MalaHistoriesTableTableManager get malaHistories =>
      $$MalaHistoriesTableTableManager(_db, _db.malaHistories);
  $$FamiliesTableTableManager get families =>
      $$FamiliesTableTableManager(_db, _db.families);
  $$FamilyTreeDataTableTableManager get familyTreeData =>
      $$FamilyTreeDataTableTableManager(_db, _db.familyTreeData);
}
