part of '../mala_japs/mala_data_table_page.dart';

class _MalaDataTablePageState extends State<MalaDataTablePage>
    with RestorationMixin {
  _MalaDataTablePageState();

  // final _RestorableDessertSelections _dessertSelections =
  //     _RestorableDessertSelections();
  final RestorableInt _rowIndex = RestorableInt(0);
  final RestorableInt _rowsPerPage =
      RestorableInt(PaginatedDataTable.defaultRowsPerPage);
  // int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  final RestorableBool _sortAscending = RestorableBool(false);
  final RestorableIntN _sortColumnIndex = RestorableIntN(0);
  final scrollController = ScrollController();
  _DessertDataSource? _dessertsDataSource;
  late MalaJapExcelFileHandler fileHandler;

  @override
  initState() {
    super.initState();
    fileHandler = MalaJapExcelFileHandler(widget.malas);
  }

  @override
  String get restorationId => 'data_table_demo';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    // registerForRestoration(_dessertSelections, 'selected_row_indices');
    registerForRestoration(_rowIndex, 'current_row_index');
    registerForRestoration(_rowsPerPage, 'rows_per_page');
    registerForRestoration(_sortAscending, 'sort_ascending');
    registerForRestoration(_sortColumnIndex, 'sort_column_index');

    _dessertsDataSource ??= _DessertDataSource(context, widget.malas);
    switch (_sortColumnIndex.value) {
      case 0:
        _dessertsDataSource!._sort<DateTime>((d) => d.date, _sortAscending.value);
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
    _rowsPerPage.dispose();
    _sortColumnIndex.dispose();
    _sortAscending.dispose();
    // _dessertsDataSource!.removeListener(_updateSelectedDessertRowListener);
    _dessertsDataSource!.dispose();
    super.dispose();
  }

  Future<void> _handleSaveExcelSuccess() async {
    await showAlertDialog(context, 'Excel file saved successfully.');
  }

  void _handleSaveExcelFailure(String error) {
    showSnackBar(context, 'Can not save excel file.\n$error');
  }

  @override
  Widget build(BuildContext context) {
    final tableItemsCount = widget.malas.length;
    final totalMalas = widget._getTotalMalas();
    final totalJaps = totalMalas * Mala.japsPerMala;
    var isRowCountLessDefaultRowsPerPage = tableItemsCount < _rowsPerPage.value;
    final rowsPerPage =
        isRowCountLessDefaultRowsPerPage ? tableItemsCount : _rowsPerPage.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mala History'),
        actions: [
          if (tableItemsCount > 0)
            IconButton(
                onPressed: () async => await fileHandler.saveExcel(
                    _handleSaveExcelSuccess, _handleSaveExcelFailure),
                icon: const Icon(Icons.file_download)),
        ],
      ),
      body: Scrollbar(
        controller: scrollController,
        child: ListView(
          controller: scrollController,
          restorationId: 'data_table_list_view',
          padding: const EdgeInsets.all(16),
          children: [
            tableItemsCount == 0
                ? const Text(
                    'No malas or japs completed yet.',
                    textAlign: TextAlign.center,
                  )
                : PaginatedDataTable(
                    header:
                        Text('Malas: $totalMalas, Japs: $totalJaps'),
                    availableRowsPerPage: [
                      rowsPerPage,
                      rowsPerPage * 2,
                      rowsPerPage * 3,
                      rowsPerPage * 4,
                      rowsPerPage * 5,
                    ],
                    rowsPerPage: rowsPerPage,
                    onRowsPerPageChanged: (value) {
                      setState(() {
                        _rowsPerPage.value = value!;
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
                        onSort: (columnIndex, ascending) => _sort<DateTime>(
                            (d) => d.date, columnIndex, ascending),
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
