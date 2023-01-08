import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:yv_counter/common/json_file_handler.dart';
import 'package:yv_counter/data_model/family_member_relation.dart';

class FamilyHandler {
  final jsonFileHendler = const JsonFileHandler();

  Future<void> loadFamily() async {
    final isar = await openIsarFamily();
    debugPrint(isar.name);
    debugPrint(isar.directory);
    debugPrint(isar.path);

    /*
    await isar.writeTxn(() async {
      await isar.familys.clear();
      await isar.members.clear();
      await isar.relations.clear();
    });
    */

    if (await isar.familys.count() == 0) {
      JsonFileHandler.fileName = JsonFileHandler.familyFileName;
      final familyString = await jsonFileHendler.readJsonFromBundle();
      final familyJson = jsonDecode(familyString);
      final family = Family('Vyas Family', id: 1);

      final List nodes = familyJson['nodes'];
      final members = nodes.map((e) {
        final names = e['label'].toString().split('\n');
        if (names.length == 2) {
          return Member(names.first, id: e['id'], spouseName: names.last);
        } else {
          return Member(names.first, id: e['id']);
        }
      });
      final List edges = familyJson['edges'];
      final relations =
          edges.map((e) => Relation(e['from'], e['to'], id: e['id']));
      debugPrint(members.toString());
      debugPrint(relations.toString());

      family.members.addAll(members);
      family.relations.addAll(relations);

      // isar.writeTxnSync(() => isar.familys.putSync(family));
      await isar.writeTxn(() async {
        await isar.familys.put(family);
        await isar.members.putAll(members.toList());
        await isar.relations.putAll(relations.toList());
        await family.members.save();
        await family.relations.save();
      });
      /*
      debugPrint(family.name);
      debugPrint(family.members.toString());
      debugPrint(family.relations.toString());
      */
    } else {
      /*
      final families = await getFamilies();
      await families.first.members.load();
      await families.first.relations.load();
      debugPrint(families.first.toString());
      */
    }
  }

  Future<Isar> openIsarFamily() async {
    return Isar.getInstance() ?? await Future.error("No db open.");
    /*
    return Isar.getInstance('family') ??
        await Isar.open([FamilySchema, MemberSchema, RelationSchema],
            name: 'family');
            */
  }

  Future<List<Family>> getFamilies() async {
    final isar = await openIsarFamily();
    return await isar.familys.where().findAll();
  }

  Future<void> saveFamily(Family family) async {
    final isar = await openIsarFamily();
    isar.writeTxn(() async => await isar.familys.put(family));
  }

  Future<void> deleteFamily(Id id) async {
    final isar = await openIsarFamily();
    isar.writeTxn(() async => await isar.familys.delete(id));
  }

  Future<void> saveMember(Member member) async {
    final isar = await openIsarFamily();
    isar.writeTxn(() async => await isar.members.put(member));
  }

  Future<void> deleteMember(Id id) async {
    final isar = await openIsarFamily();
    isar.writeTxn(() async => await isar.members.delete(id));
  }

  Future<void> saveRelation(Relation relation) async {
    final isar = await openIsarFamily();
    isar.writeTxn(() async => await isar.relations.put(relation));
  }

  Future<void> deleteRelation(Id id) async {
    final isar = await openIsarFamily();
    isar.writeTxn(() async => await isar.relations.delete(id));
  }
}
