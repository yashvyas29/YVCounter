import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

String listMyNodeJSON(List<MyNode> lst) {
  Map<String, String> mapMyNodeJSON = {};
  for (int i = 0; i < lst.length; i++) {
    mapMyNodeJSON[lst[i].id.toString()] = lst[i].text;
  }
  return jsonEncode(mapMyNodeJSON);
}

Future<String> localPath() async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<File> localFile() async {
  final path = await localPath();
  return File('$path/tree.json');
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
    // Delete the file
    // file.deleteSync();
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

class MyNode {
  int id = 0;
  String text = "";

  MyNode(this.id, this.text);

  Future<void> updateText(String text, List<MyNode> list) async {
    this.text = text;
    await writeJson(listMyNodeJSON(list));
  }

  @override
  String toString() {
    return "$id---$text";
  }

  MyNode.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        text = json['text'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
      };
}
