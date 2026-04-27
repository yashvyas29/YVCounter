part of 'mala_data_table_page.dart';

class _MalaDataTablePageState extends State<MalaDataTablePage>
    with RestorationMixin {
  _MalaDataTablePageState();

  final RestorableInt _rowIndex = RestorableInt(0);
  final RestorableInt _rowsPerPage = RestorableInt(
    PaginatedDataTable.defaultRowsPerPage,
  );
  final RestorableBool _sortAscending = RestorableBool(false);
  final RestorableIntN _sortColumnIndex = RestorableIntN(0);
  final scrollController = ScrollController();
  final chartScrollController = ScrollController();
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
    registerForRestoration(_rowIndex, 'current_row_index');
    registerForRestoration(_rowsPerPage, 'rows_per_page');
    registerForRestoration(_sortAscending, 'sort_ascending');
    registerForRestoration(_sortColumnIndex, 'sort_column_index');

    _dessertsDataSource ??= _DessertDataSource(context, widget.malas);
    switch (_sortColumnIndex.value) {
      case 0:
        _dessertsDataSource!._sort<DateTime>(
          (d) => d.date,
          _sortAscending.value,
        );
        break;
      case 1:
        _dessertsDataSource!._sort<num>((d) => d.count, _sortAscending.value);
        break;
      case 2:
        _dessertsDataSource!._sort<num>((d) => d.japs, _sortAscending.value);
        break;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dessertsDataSource ??= _DessertDataSource(context, widget.malas);
  }

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
    _dessertsDataSource!.dispose();
    scrollController.dispose();
    chartScrollController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveExcelSuccess() async {
    await showAlertDialog(
      context,
      AppLocalizations.of(context).excelSaveSuccessful,
    );
  }

  void _handleSaveExcelFailure(String error) {
    showSnackBar(context, '${AppLocalizations.of(context).saveError}\n$error');
  }

  Widget _buildOverviewTab(
    AppLocalizations localizations,
    String malaLabel,
    String japLabel,
  ) {
    if (widget.malas.isEmpty) {
      return Center(child: Text(localizations.malaNotAvailable));
    }

    return SingleChildScrollView(
      controller: chartScrollController,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.last7Days,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 200,
                    child: MalaWeeklyChart(
                      malas: widget.malas,
                      malaLabel: malaLabel,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.last30Days,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 200,
                    child: MalaLast30DaysChart(
                      malas: widget.malas,
                      malaLabel: malaLabel,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.last12Months,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 200,
                    child: MalaMonthlyChart(
                      malas: widget.malas,
                      malaLabel: malaLabel,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(
    AppLocalizations localizations,
    String malaLabel,
    String japLabel,
  ) {
    final tableItemsCount = widget.malas.length;
    var isRowCountLessDefaultRowsPerPage = tableItemsCount < _rowsPerPage.value;
    final rowsPerPage = isRowCountLessDefaultRowsPerPage
        ? tableItemsCount
        : _rowsPerPage.value;

    return Scrollbar(
      controller: scrollController,
      child: tableItemsCount == 0
          ? Center(child: Text(localizations.malaNotAvailable))
          : ListView(
              controller: scrollController,
              restorationId: 'data_table_list_view',
              padding: const EdgeInsets.all(16),
              children: [
                PaginatedDataTable(
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
                  showCheckboxColumn: false,
                  showFirstLastButtons: !isRowCountLessDefaultRowsPerPage,
                  columns: [
                    DataColumn(
                      label: Text(localizations.date),
                      onSort: (columnIndex, ascending) => _sort<DateTime>(
                        (d) => d.date,
                        columnIndex,
                        ascending,
                      ),
                    ),
                    DataColumn(
                      label: Text(malaLabel),
                      numeric: true,
                      onSort: (columnIndex, ascending) =>
                          _sort<num>((d) => d.count, columnIndex, ascending),
                    ),
                    DataColumn(
                      label: Text(japLabel),
                      numeric: true,
                      onSort: (columnIndex, ascending) =>
                          _sort<num>((d) => d.japs, columnIndex, ascending),
                    ),
                  ],
                  source: _dessertsDataSource!,
                ),
              ],
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsModel>(context);
    final malaLabel = settings.getLocalizedPrimaryLabel(context);
    final japLabel = settings.getLocalizedSecondaryLabel(context);
    final localizations = AppLocalizations.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(localizations.malaProgress),
          actions: [
            if (widget.malas.isNotEmpty)
              IconButton(
                onPressed: () async => await fileHandler.saveExcel(
                  _handleSaveExcelSuccess,
                  _handleSaveExcelFailure,
                ),
                icon: const Icon(Icons.file_download),
              ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(
                icon: const Icon(Icons.bar_chart),
                text: localizations.overview,
              ),
              Tab(icon: const Icon(Icons.list), text: localizations.history),
            ],
          ),
        ),
        body: Column(
          children: [
            if (widget.malas.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: MalaStatsCard(
                  malas: widget.malas,
                  malaLabel: malaLabel,
                  japLabel: japLabel,
                  localizations: localizations,
                ),
              ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildOverviewTab(localizations, malaLabel, japLabel),
                  _buildHistoryTab(localizations, malaLabel, japLabel),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
