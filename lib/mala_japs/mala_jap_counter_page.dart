import 'dart:convert';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:path/path.dart' as p;
// import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yv_counter/about_page.dart';
import 'package:yv_counter/common/date_time_handler.dart';
import 'package:yv_counter/common/json_file_handler.dart';
import 'package:yv_counter/common/sqlite_db_provider.dart';
import 'package:yv_counter/family_members/family_list_page.dart';
import 'package:yv_counter/common/google_drive.dart';
import 'package:yv_counter/data_model/mala.dart';
// import 'package:yv_counter/famity_tree/pages/homepage.dart';
import 'package:yv_counter/mala_japs/mala_data_table_page.dart';
import 'package:yv_counter/common/shared_pref.dart';
import 'package:yv_counter/data_model/user.dart';
import 'package:yv_counter/common/snackbar_dialog.dart';

import 'mala_jap_excel_file_handler.dart';

// import '../common/family_handler.dart';

part '../mala_japs/mala_jap_counter_page_state.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

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
      final fileBytes = file.bytes;
      if (fileBytes != null) {
        return await _restoreMalasFromExcel(fileBytes);
      } else {
        final filePath = file.path;
        if (filePath != null) {
          final file = File(filePath);
          final fileBytes = await file.readAsBytes();
          return await _restoreMalasFromExcel(fileBytes);
        }
      }
    }
    return [];
  }

  Future<List<Mala>> _restoreMalasFromExcel(Uint8List fileBytes) async {
    final excel = Excel.decodeBytes(fileBytes);
    for (final table in excel.tables.keys) {
      debugPrint(table); //sheet Name
      final sheet = excel.tables[table];
      if (sheet != null) {
        debugPrint(sheet.maxColumns.toString());
        debugPrint(sheet.maxRows.toString());
        final List<Mala> malas = [];
        sheet.rows.asMap().forEach((rowIndex, rowValue) {
          if (rowIndex > 0) {
            late String date;
            late int malasCount;
            late int japs;
            rowValue.asMap().forEach((columnIndex, columnData) {
              if (columnData != null) {
                final columnValue = columnData.value.toString();
                switch (columnIndex) {
                  case 0:
                    date = columnValue;
                    break;
                  case 1:
                    malasCount = int.parse(columnValue);
                    break;
                  case 2:
                    japs = int.parse(columnValue);
                }
              }
            });
            malas.add(Mala(
                DateTimeHandler.getDateTime(date, DateTimeHandler.dateFormat),
                malasCount,
                japs));
          }
        });
        return malas;
      }
    }
    return [];
  }

  /*
  Future<Isar> openIsarMala() async {
    return Isar.getInstance() ?? await Future.error("No db open.");
  }

  Future<List<Mala>> _getMalas() async {
    final isar = await openIsarMala();
    return await isar.malas.where().findAll();
  }

  Future<void> _saveMalas(List<Mala> malas) async {
    final isar = await openIsarMala();
    isar.writeTxn(() async => await isar.malas.putAllByDate(malas));
  }

  Future<void> deleteMalaByDate(String date) async {
    final isar = await openIsarMala();
    isar.writeTxn(() async => await isar.malas.deleteByDate(date));
  }
  */
}

// This is the type used by the popup menu below.
enum Menu { backup, restore, backupExcel, restoreExcel, delete, signOut }
