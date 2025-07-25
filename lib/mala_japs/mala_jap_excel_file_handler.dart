import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yv_counter/common/date_time_handler.dart';

import '../data_model/mala.dart';

class MalaJapExcelFileHandler {
  const MalaJapExcelFileHandler(this.malas);

  final List<Mala> malas;

  Future<Excel> _createExcel() async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Mala History'];

    CellStyle cellStyle = CellStyle(
      backgroundColorHex: ExcelColor.fromHexString("#1AFF1A"),
      fontFamily: getFontFamily(FontFamily.Calibri),
    );

    cellStyle.underline = Underline.Single; // or Underline.Double

    var cell1 = sheetObject.cell(CellIndex.indexByString("A1"));
    cell1.value = TextCellValue('Date'); // dynamic values support provided;
    cell1.cellStyle = cellStyle;

    var cell2 = sheetObject.cell(CellIndex.indexByString("B1"));
    cell2.value = TextCellValue('Malas'); // dynamic values support provided;
    cell2.cellStyle = cellStyle;

    var cell3 = sheetObject.cell(CellIndex.indexByString("C1"));
    cell3.value = TextCellValue('Japs'); // dynamic values support provided;
    cell3.cellStyle = cellStyle;

    malas.asMap().forEach((index, mala) {
      sheetObject.insertRowIterables([
        TextCellValue(
          DateTimeHandler.getString(mala.date, DateTimeHandler.dateFormat),
        ),
        IntCellValue(mala.count),
        IntCellValue(mala.japs),
      ], index + 1);
    });

    final defaultSheet = excel.getDefaultSheet();
    if (defaultSheet != null) {
      /// deleting the sheet
      excel.delete(defaultSheet);
    }

    return excel;
  }

  Future<void> saveExcel(
    final Future<void> Function() onSuccess,
    final void Function(String) onFailure,
  ) async {
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
          await file.writeAsBytes(fileBytes);
          await onSuccess.call();
        } catch (error) {
          debugPrint(error.toString());
          onFailure.call(error.toString());
        }
      } else {
        onFailure.call("");
      }
    }
  }

  Future<void> createAndSaveExcelOnDesktop(
    final Future<void> Function() onSuccess,
    final void Function(String) onFailure,
  ) async {
    final Excel excel = await _createExcel();
    List<int>? fileBytes = excel.save();
    if (fileBytes != null && fileBytes.isNotEmpty) {
      try {
        const fileName = 'malas.xlsx';
        final filePath = await FilePicker.platform.saveFile(
          fileName: fileName,
          type: FileType.custom,
          allowedExtensions: ['xlsx'],
        );
        /*
        final filePath = await FlutterFileSaver().writeFileAsBytes(
          fileName: fileName,
          bytes: Uint8List.fromList(fileBytes),
        );
        */
        if (filePath == null) {
          onFailure.call("Cancelled");
        } else {
          await File(filePath).writeAsBytes(fileBytes);
          await onSuccess.call();
        }
      } catch (error) {
        debugPrint(error.toString());
        onFailure.call(error.toString());
      }
    } else {
      onFailure.call("");
    }
  }

  Future<void> createAndSaveExcelOnMobile(
    final Future<void> Function() onSuccess,
    final void Function(String) onFailure,
  ) async {
    final Excel excel = await _createExcel();
    // List<int>? fileBytes = excel.encode();
    List<int>? fileBytes = excel.save();
    if (fileBytes != null && fileBytes.isNotEmpty) {
      try {
        const fileName = 'malas.xlsx';
        final params = SaveFileDialogParams(
          data: Uint8List.fromList(fileBytes),
          fileName: fileName,
        );
        final filePath = await FlutterFileDialog.saveFile(params: params);
        /*
        var file = await _createTempExcel(fileName, fileBytes);
        final params = SaveFileDialogParams(
            sourceFilePath: file.path, destinationFileName: fileName);
        final filePath = await CRFileSaver.saveFileWithDialog(params);
        file.delete();
        */
        if (filePath == null) {
          onFailure.call("Cancelled");
        } else {
          await onSuccess.call();
        }
      } catch (error) {
        debugPrint(error.toString());
        onFailure.call(error.toString());
      }
    } else {
      onFailure.call("");
    }
  }

  /*
  /// Create example file in temporary directory to work with
  Future<File> createTempExcel(String fileName, List<int> fileBytes) async {
    final folder = await getTemporaryDirectory();
    final filePath = '${folder.path}/$fileName';
    final file = File(filePath);
    return await file.writeAsBytes(fileBytes);
  }
  */

  Future<String> _getExcelFilePath() async {
    Directory directory;
    if (Platform.isAndroid) {
      /*
      const storagePermission = Permission.storage;
      final isPermissionGranted = await storagePermission.isGranted;
      if (!isPermissionGranted) {
        storagePermission.request();
      }
      */
      final downloadDirectory = Directory('/storage/emulated/0/Download');
      final downloadDirectoryExists = await downloadDirectory.exists();
      directory = downloadDirectoryExists
          ? downloadDirectory
          : await getApplicationDocumentsDirectory();
    } else if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      directory =
          await getDownloadsDirectory() ??
          await getApplicationDocumentsDirectory();
    } else {
      directory = await getApplicationDocumentsDirectory();
    }
    return join(directory.path, 'malas.xlsx');
  }
}
