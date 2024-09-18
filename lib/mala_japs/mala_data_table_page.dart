import 'package:flutter/material.dart';
import 'package:yv_counter/common/date_time_handler.dart';
import 'package:yv_counter/common/snackbar_dialog.dart';
import 'package:yv_counter/data_model/mala.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'mala_jap_excel_file_handler.dart';

part '../mala_japs/mala_data_table_page_state.dart';

class MalaDataTablePage extends StatefulWidget {
  const MalaDataTablePage({super.key, required this.malas});

  final List<Mala> malas;

  @override
  State<MalaDataTablePage> createState() => _MalaDataTablePageState();

  int _getTotalMalas() {
    return malas.fold(0, (sum, mala) => sum + mala.count);
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
        DataCell(Text(DateTimeHandler.getString(
            dessert.date,
            DateTimeHandler.isToday(dessert.date)
                ? DateTimeHandler.dateTimeFormat
                : DateTimeHandler.dateFormat))),
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
