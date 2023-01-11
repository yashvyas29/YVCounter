import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../data_model/mala.dart';

class MalaJapExcelFileHandler {
  const MalaJapExcelFileHandler(this.malas);

  final List<Mala> malas;

  Future<Excel> _createExcel() async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Mala History'];

    CellStyle cellStyle = CellStyle(
        backgroundColorHex: "#1AFF1A",
        fontFamily: getFontFamily(FontFamily.Calibri));

    cellStyle.underline = Underline.Single; // or Underline.Double

    var cell1 = sheetObject.cell(CellIndex.indexByString("A1"));
    cell1.value = 'Date'; // dynamic values support provided;
    cell1.cellStyle = cellStyle;

    var cell2 = sheetObject.cell(CellIndex.indexByString("B1"));
    cell2.value = 'Malas'; // dynamic values support provided;
    cell2.cellStyle = cellStyle;

    var cell3 = sheetObject.cell(CellIndex.indexByString("C1"));
    cell3.value = 'Japs'; // dynamic values support provided;
    cell3.cellStyle = cellStyle;

    malas.asMap().forEach((index, mala) {
      sheetObject
          .insertRowIterables([mala.date, mala.count, mala.japs], index + 1);
    });

    final defaultSheet = excel.getDefaultSheet();
    if (defaultSheet != null) {
      /// deleting the sheet
      excel.delete(defaultSheet);
    }

    return excel;
  }

  Future<void> saveExcel(
      final Function() onSuccess, final Function(String) onFailure) async {
    final Excel excel = await _createExcel();
    if (kIsWeb) {
      excel.save(fileName: 'malas.xlsx');
      onSuccess.call();
    } else {
      // List<int>? fileBytes = excel.encode();
      List<int>? fileBytes = excel.save();
      if (fileBytes != null && fileBytes.isNotEmpty) {
        final file = File(await _getExcelFilePath());
        try {
          if (!await file.exists()) {
            await file.create(recursive: true);
          }
          await file.writeAsBytes(fileBytes);
          onSuccess.call();
        } catch (error) {
          debugPrint(error.toString());
          onFailure.call(error.toString());
        }
      } else {
        onFailure.call("");
      }
    }
  }

  Future<void> createAndSaveExcelOnMobile(
      final Function() onSuccess, final Function(String) onFailure) async {
    final Excel excel = await _createExcel();
    // List<int>? fileBytes = excel.encode();
    List<int>? fileBytes = excel.save();
    if (fileBytes != null && fileBytes.isNotEmpty) {
      try {
        final params = SaveFileDialogParams(
            data: Uint8List.fromList(fileBytes), fileName: 'malas.xlsx');
        final filePath = await FlutterFileDialog.saveFile(params: params);
        if (filePath == null) {
          onFailure.call("Cancelled");
        } else {
          onSuccess.call();
        }
      } catch (error) {
        debugPrint(error.toString());
        onFailure.call(error.toString());
      }
    } else {
      onFailure.call("");
    }
  }

  Future<String> _getExcelFilePath() async {
    Directory directory;
    if (Platform.isAndroid) {
      const storagePermission = Permission.storage;
      final isPermissionGranted = await storagePermission.isGranted;
      if (!isPermissionGranted) {
        storagePermission.request();
      }
      final downloadDirectory = Directory('/storage/emulated/0/Download');
      final downloadDirectoryExists = await downloadDirectory.exists();
      directory = downloadDirectoryExists
          ? downloadDirectory
          : await getApplicationDocumentsDirectory();
    } else if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      directory = await getDownloadsDirectory() ??
          await getApplicationDocumentsDirectory();
    } else {
      directory = await getApplicationDocumentsDirectory();
    }
    return join(directory.path, 'malas.xlsx');
  }
}
