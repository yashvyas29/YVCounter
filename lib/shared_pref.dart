import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yv_counter/mala.dart';

class SharedPref {
  read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(key);
    return value == null ? "" : json.decode(value);
  }

  save(String key, value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, json.encode(value));
  }

  Future<List<Mala>> readList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(key);
    return list == null
        ? []
        : list.map((value) => Mala.fromJson(json.decode(value))).toList();
  }

  saveList(String key, List<Mala> malas) async {
    final list = malas.map((mala) => json.encode(mala.toJson())).toList();
    debugPrint(list.join('\n'));
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(key, list);
  }

  remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
