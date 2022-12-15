import 'dart:convert';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yv_counter/about_page.dart';
import 'package:yv_counter/family_tree/family_tree_page.dart';
import 'package:yv_counter/common/google_drive.dart';
import 'package:yv_counter/data_model/mala.dart';
import 'package:yv_counter/mala_data_table_page.dart';
import 'package:yv_counter/common/shared_pref.dart';
import 'package:yv_counter/data_model/user.dart';

part 'my_home_page_state.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();

  void _playBeep([bool success = true]) {
    if (!kIsWeb && Platform.isAndroid) {
      FlutterBeep.beep(success);
    } else {
      SystemSound.play(SystemSoundType.click);
    }
  }

  void _playAlertSysSound() {
    if (!kIsWeb && Platform.isAndroid) {
      FlutterBeep.playSysSound(AndroidSoundIDs.TONE_CDMA_ABBR_ALERT);
    } else {
      SystemSound.play(SystemSoundType.alert);
    }
  }

  Future<List<Mala>> _getMalasFromExcel() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );
    final file = result?.files.single;
    if (file != null) {
      debugPrint(file.name);
      final filePath = file.path;
      debugPrint(filePath);
      if (filePath != null) {
        final file = File(filePath);
        final fileBytes = await file.readAsBytes();
        final excel = Excel.decodeBytes(fileBytes);
        for (var table in excel.tables.keys) {
          debugPrint(table); //sheet Name
          final sheet = excel.tables[table];
          if (sheet != null) {
            debugPrint(sheet.maxCols.toString());
            debugPrint(sheet.maxRows.toString());
            final List<Mala> malas = [];
            sheet.rows.asMap().forEach((rowIndex, rowValue) {
              if (rowIndex > 0) {
                late String date;
                late int malasCount;
                late int japs;
                rowValue.asMap().forEach((columnIndex, columnData) {
                  if (columnData != null) {
                    final columnValue = columnData.value;
                    switch (columnIndex) {
                      case 0:
                        date = columnValue;
                        break;
                      case 1:
                        malasCount = columnValue;
                        break;
                      case 2:
                        japs = columnValue;
                    }
                  }
                });
                malas.add(Mala(date, malasCount, japs));
              }
            });
            return malas;
          }
        }
      }
    }
    return [];
  }
}

// This is the type used by the popup menu below.
enum Menu { signIn, backup, restore, restoreExcel, delete, signOut }
