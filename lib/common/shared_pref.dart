import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:yv_counter/data_model/mala.dart';

class SharedPref {
  Future<String> read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(key);
    return value == null ? "" : json.decode(value);
  }

  Future<void> save(String key, value) async {
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

  Future<void> saveList(String key, List<Mala> malas) async {
    final list = malas.map((mala) => json.encode(mala.toJson())).toList();
    // debugPrint(list.join('\n'));
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(key, list);
  }

  Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
