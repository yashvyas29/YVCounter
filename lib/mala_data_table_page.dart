import 'package:flutter/material.dart';
import 'package:yv_counter/mala.dart';

class MalaDataTablePage extends StatefulWidget {
  const MalaDataTablePage({super.key, required this.malas});

  final List<Mala> malas;
  @override
  State<MalaDataTablePage> createState() => _MalaDataTablePageState();
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

class _MalaDataTablePageState extends State<MalaDataTablePage>
    with RestorationMixin {
  _MalaDataTablePageState();

  // final _RestorableDessertSelections _dessertSelections =
  //     _RestorableDessertSelections();
  final RestorableInt _rowIndex = RestorableInt(0);
  // final RestorableInt _rowsPerPage =
  //     RestorableInt(PaginatedDataTable.defaultRowsPerPage);
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  final RestorableBool _sortAscending = RestorableBool(false);
  final RestorableIntN _sortColumnIndex = RestorableIntN(0);
  final scrollController = ScrollController();
  _DessertDataSource? _dessertsDataSource;

  @override
  String get restorationId => 'data_table_demo';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    // registerForRestoration(_dessertSelections, 'selected_row_indices');
    registerForRestoration(_rowIndex, 'current_row_index');
    // registerForRestoration(_rowsPerPage, 'rows_per_page');
    registerForRestoration(_sortAscending, 'sort_ascending');
    registerForRestoration(_sortColumnIndex, 'sort_column_index');

    _dessertsDataSource ??= _DessertDataSource(context, widget.malas);
    switch (_sortColumnIndex.value) {
      case 0:
        _dessertsDataSource!._sort<String>((d) => d.date, _sortAscending.value);
        break;
      case 1:
        _dessertsDataSource!._sort<num>((d) => d.count, _sortAscending.value);
        break;
      case 2:
        _dessertsDataSource!._sort<num>((d) => d.japs, _sortAscending.value);
        break;
    }
    // _dessertsDataSource!.updateSelectedDesserts(_dessertSelections);
    // _dessertsDataSource!.addListener(_updateSelectedDessertRowListener);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dessertsDataSource ??= _DessertDataSource(context, widget.malas);
    // _dessertsDataSource!.addListener(_updateSelectedDessertRowListener);
  }

  // void _updateSelectedDessertRowListener() {
  //   _dessertSelections.setDessertSelections(_dessertsDataSource!._desserts);
  // }

  void _sort<T>(
    Comparable<T> Function(Mala d) getField,
    int columnIndex,
    bool ascending,
  ) {
    _dessertsDataSource!._sort<T>(getField, ascending);
    setState(() {
      _sortColumnIndex.value = columnIndex;
      _sortAscending.value = ascending;
    });
  }

  @override
  void dispose() {
    // _rowsPerPage.dispose();
    _sortColumnIndex.dispose();
    _sortAscending.dispose();
    // _dessertsDataSource!.removeListener(_updateSelectedDessertRowListener);
    _dessertsDataSource!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var tableItemsCount = widget.malas.length;
    var defaultRowsPerPage = PaginatedDataTable.defaultRowsPerPage;
    var isRowCountLessDefaultRowsPerPage = tableItemsCount < defaultRowsPerPage;
    _rowsPerPage =
        isRowCountLessDefaultRowsPerPage ? tableItemsCount : defaultRowsPerPage;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mala History'),
      ),
      body: Scrollbar(
        controller: scrollController,
        child: ListView(
          controller: scrollController,
          restorationId: 'data_table_list_view',
          padding: const EdgeInsets.all(16),
          children: [
            PaginatedDataTable(
              header: const Text('Japs Mala'),
              rowsPerPage: _rowsPerPage,
              onRowsPerPageChanged: isRowCountLessDefaultRowsPerPage
                  ? null
                  : (value) {
                      setState(() {
                        _rowsPerPage = value!;
                      });
                    },
              initialFirstRowIndex: _rowIndex.value,
              onPageChanged: (rowIndex) {
                setState(() {
                  _rowIndex.value = rowIndex;
                });
              },
              sortColumnIndex: _sortColumnIndex.value,
              sortAscending: _sortAscending.value,
              // onSelectAll: _dessertsDataSource!._selectAll,
              showCheckboxColumn: false,
              showFirstLastButtons: !isRowCountLessDefaultRowsPerPage,
              columns: [
                DataColumn(
                  label: const Text('Date'),
                  onSort: (columnIndex, ascending) =>
                      _sort<String>((d) => d.date, columnIndex, ascending),
                ),
                DataColumn(
                  label: const Text('Malas'),
                  numeric: true,
                  onSort: (columnIndex, ascending) =>
                      _sort<num>((d) => d.count, columnIndex, ascending),
                ),
                DataColumn(
                  label: const Text('Japs'),
                  numeric: true,
                  onSort: (columnIndex, ascending) =>
                      _sort<num>((d) => d.japs, columnIndex, ascending),
                ),
              ],
              source: _dessertsDataSource!,
            ),
          ],
        ),
      ),
    );
  }
}

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
