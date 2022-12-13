import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:yv_counter/mala.dart';
import 'package:path/path.dart' as p;

part 'mala_data_table_page_state.dart';

class MalaDataTablePage extends StatefulWidget {
  const MalaDataTablePage({super.key, required this.malas});

  final List<Mala> malas;
  @override
  State<MalaDataTablePage> createState() => _MalaDataTablePageState();

  int _getTotalMalas() {
    return malas.fold(0, (sum, mala) => sum + mala.count);
  }

  Future<void> _createExcel(VoidCallback onSuccess) async {
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

    /// Inserting and removing column and rows

    // insert column at index = 8
    // sheetObject.insertColumn(8);

    // remove column at index = 18
    // sheetObject.removeColumn(18);

    // insert row at index = 82
    malas.asMap().forEach((index, mala) {
      sheetObject
          .insertRowIterables([mala.date, mala.count, mala.japs], index + 1);
    });

    // remove row at index = 80
    // sheetObject.removeRow(80);

    final defaultSheet = excel.getDefaultSheet();
    if (defaultSheet != null) {
      /// deleting the sheet
      excel.delete(defaultSheet);
    }

    // Save the Changes in file
    Directory directory;
    if (kIsWeb) {
      excel.save(fileName: 'malas.xlsx');
      onSuccess.call();
    } else {
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
      String outputFile = p.join(directory.path, 'malas.xlsx');
      debugPrint(outputFile);
      // File(outputFile).writeAsBytes(excel.encode());
      List<int>? fileBytes = excel.save();
      if (fileBytes != null) {
        final file = File(outputFile);
        file
          ..createSync(recursive: true)
          ..writeAsBytesSync(fileBytes);
        onSuccess.call();
      }
    }
  }
}

/*
class _RestorableDessertSelections extends RestorableProperty<Set<int>> {
  Set<int> _dessertSelections = {};

  /// Returns whether or not a dessert row is selected by index.
  bool isSelected(int index) => _dessertSelections.contains(index);

  /// Takes a list of [Mala]s and saves the row indices of selected rows
  /// into a [Set].
  void setDessertSelections(List<Mala> desserts) {
    final updatedSet = <int>{};
    for (var i = 0; i < desserts.length; i += 1) {
      var dessert = desserts[i];
      if (dessert.selected) {
        updatedSet.add(i);
      }
    }
    _dessertSelections = updatedSet;
    notifyListeners();
  }

  @override
  Set<int> createDefaultValue() => _dessertSelections;

  @override
  Set<int> fromPrimitives(Object? data) {
    final selectedItemIndices = data as List<dynamic>;
    _dessertSelections = {
      ...selectedItemIndices.map<int>((dynamic id) => id as int),
    };
    return _dessertSelections;
  }

  @override
  void initWithValue(Set<int> value) {
    _dessertSelections = value;
  }

  @override
  Object toPrimitives() => _dessertSelections.toList();
}
*/

class _DessertDataSource extends DataTableSource {
  _DessertDataSource(this.context, this._desserts);

  final BuildContext context;
  final List<Mala> _desserts;

  void _sort<T>(Comparable<T> Function(Mala d) getField, bool ascending) {
    _desserts.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });
    notifyListeners();
  }

  final int _selectedCount = 0;

  /*
  void updateSelectedDesserts(_RestorableDessertSelections selectedRows) {
    _selectedCount = 0;
    for (var i = 0; i < _desserts.length; i += 1) {
      var dessert = _desserts[i];
      if (selectedRows.isSelected(i)) {
        dessert.selected = true;
        _selectedCount += 1;
      } else {
        dessert.selected = false;
      }
    }
    notifyListeners();
  }
  */

  @override
  DataRow? getRow(int index) {
    assert(index >= 0);
    if (index >= _desserts.length) return null;
    final dessert = _desserts[index];
    return DataRow.byIndex(
      index: index,
      /*
      selected: dessert.selected,
      onSelectChanged: (value) {
        if (dessert.selected != value) {
          _selectedCount += value! ? 1 : -1;
          assert(_selectedCount >= 0);
          dessert.selected = value;
          notifyListeners();
        }
      },
      */
      cells: [
        DataCell(Text(dessert.date)),
        DataCell(Text('${dessert.count}')),
        DataCell(Text('${dessert.japs}')),
      ],
    );
  }

  @override
  int get rowCount => _desserts.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;

  // void _selectAll(bool? checked) {
  //   for (final dessert in _desserts) {
  //     dessert.selected = checked ?? false;
  //   }
  //   _selectedCount = checked! ? _desserts.length : 0;
  //   notifyListeners();
  // }
}
