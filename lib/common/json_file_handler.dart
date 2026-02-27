import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class JsonFileHandler {
  const JsonFileHandler();

  Future<String> localPath() async {
    final directory = await getApplicationDocumentsDirectory();
    final jsonsDir = await Directory(join(directory.path, 'jsons')).create();
    // debugPrint(jsonsDir.path);
    return jsonsDir.path;
  }

  Future<File> localFile(String fileName) async {
    final path = await localPath();
    return File(join(path, '$fileName.json'));
  }

  Future<List<String>> files() async {
    final directory = Directory(await localPath());
    final list = directory.listSync();
    for (final file in list) {
      debugPrint(file.path);
      // await file.delete();
    }
    return list.map((e) => e.path).toList();
  }

  Future<File> writeJson(String fileName, String text) async {
    final file = await localFile(fileName);
    return file.writeAsString(text);
  }

  Future<File> writeJsonData(String fileName, Map<String, dynamic> map) async {
    final file = await localFile(fileName);
    return file.writeAsString(jsonEncode(map));
  }

  Future<Map<String, dynamic>> readJson(String fileName) async {
    debugPrint("readJson");
    try {
      final file = await localFile(fileName);
      // Read the file
      final content = await file.readAsString();
      // debugPrint(content);
      return jsonDecode(content);
    } catch (error) {
      debugPrint(error.toString());
      return {};
    }
  }

  Future<Map<String, dynamic>> readJsonFromBundle(String fileName) async {
    debugPrint("readJsonFromBundle");
    try {
      final content = await readJsonStringFromBundle(fileName);
      return await jsonDecode(content);
    } catch (error) {
      debugPrint(error.toString());
      return {};
    }
  }

  Future<String> readJsonStringFromBundle(String fileName) async {
    debugPrint("readJsonStringFromBundle");
    try {
      String filePath = 'lib/resources/$fileName.json';
      return await rootBundle.loadString(filePath);
    } catch (error) {
      debugPrint(error.toString());
      return Future.error(error);
    }
  }

  Future<void> deleteLocalFile(String fileName) async {
    try {
      final file = await localFile(fileName);
      // Delete the file
      await file.delete();
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  String getFamilyFileName(String name) {
    final trimedName = name.trim();
    switch (trimedName) {
      case 'आध्यात्मिक परिवार':
        return "spritual_family_hi";
      case 'सूर्य परिवार':
        return "sury_family_hi";
      case 'चंद्र परिवार':
        return "chandr_family_hi";
      case 'व्यास परिवार':
        return 'vyas_family_hi';
      case 'कड़वावत परिवार':
        return 'kadvawat_family_hi';
      case 'धर्मावत परिवार':
        return 'dharmawat_family_hi';
      case 'लोक':
        return 'lok_hi';
      case 'भूलोक':
        return 'bhulok_hi';
      case 'त्रिलोक':
        return 'trilok_hi';
      default:
        return trimedName.toLowerCase().replaceAll(' ', '_');
    }
  }

  Future<File> renameFile(String oldFileName, String newFileName) async {
    var file = await localFile(oldFileName);
    var path = file.path;
    var lastSeparator = path.lastIndexOf(Platform.pathSeparator);
    var newPath = '${path.substring(0, lastSeparator + 1)}$newFileName.json';
    return file.rename(newPath);
  }
}

class FamilyJsonKey {
  static const nodes = "nodes";
  static const id = "id";
  static const label = "label";
  static const readOnly = "readOnly";
  static const isRoot = "isRoot";
  static const isRootChild = "isRootChild";

  static const edges = "edges";
  static const from = "from";
  static const to = "to";
}
