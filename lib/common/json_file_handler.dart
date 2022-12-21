import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yv_counter/data_model/my_node.dart';

class JsonFileHandler {
  const JsonFileHandler();
  static const familyFileName = "family.json";
  static const family1FileName = "family1.json";
  static String fileName = familyFileName;

  String listMyNodeJSON(List<MyNode> lst) {
    Map<String, String> mapMyNodeJSON = {};
    for (int i = 0; i < lst.length; i++) {
      mapMyNodeJSON[lst[i].id.toString()] = lst[i].label;
    }
    return jsonEncode(mapMyNodeJSON);
  }

  Future<String> localPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> localFile() async {
    final path = await localPath();
    return File('$path/$familyFileName');
  }

  Future<File> writeJson(String text) async {
    final file = await localFile();
    return file.writeAsString(text);
  }

  Future<File> writeJsonData(Map<String, dynamic> map) async {
    final file = await localFile();
    return file.writeAsString(jsonEncode(map));
  }

  Future<Map<String, dynamic>> readJson() async {
    debugPrint("readJson");
    try {
      final file = await localFile();
      // Read the file
      final content = await file.readAsString();
      // debugPrint(content);
      return jsonDecode(content);
    } catch (e) {
      debugPrint(e.toString());
      // If encountering an error, return empty string
      return {};
    }
  }

  Future<String> readJsonFromBundle() async {
    String filePath = 'lib/resources/$fileName';
    return rootBundle.loadString(filePath);
  }

  Future<void> deleteLocalFile() async {
    try {
      final file = await localFile();
      // Delete the file
      file.deleteSync();
    } catch (error) {
      debugPrint(error.toString());
    }
  }
}
