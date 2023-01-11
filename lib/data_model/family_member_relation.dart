/*
import 'package:isar/isar.dart';
part 'family_member_relation.g.dart';

@collection
class Family {
  final Id id;
  final String name;
  final members = IsarLinks<Member>();
  final relations = IsarLinks<Relation>();

  Family(
    this.name, {
    this.id = Isar.autoIncrement,
  });

  @override
  String toString() {
    return "$id-$name\n$members\n$relations";
  }
}

@collection
class Member {
  final Id id;
  final String name;
  @enumerated
  final Gender gender;
  final String? spouseName;
  @Backlink(to: 'members')
  final family = IsarLink<Family>();

  Member(
    this.name, {
    this.id = Isar.autoIncrement,
    this.gender = Gender.male,
    this.spouseName,
  });

  @override
  String toString() {
    return "$id-$name-$gender-$spouseName";
  }
}

@collection
class Relation {
  final Id id;
  final int parentId;
  @Index(composite: [CompositeIndex('parentId')])
  final int childId;
  @Backlink(to: 'relations')
  final family = IsarLink<Family>();

  Relation(
    this.parentId,
    this.childId, {
    this.id = Isar.autoIncrement,
  });

  @override
  String toString() {
    return "$id-$parentId-$childId";
  }
}

enum Gender { male, female }
*/