part of '../mala_japs/mala_jap_counter_page.dart';

class _MyHomePageState extends State<MyHomePage> {
  late Mala _mala;
  List<Mala> _malaList = [];
  User? _user;

  final GoogleDrive _googleDrive = GoogleDrive();
  final SharedPref _sharedPref = SharedPref();
  final List<bool> _selections = [true, false];

  @override
  void initState() {
    super.initState();
    _googleDrive.signInSilently().then((value) {
      _googleDrive.getUser().then((user) {
        setState(() {
          _user = user;
        });
      });
    });
    _mala = Mala(DateTimeHandler.today, 0, 0);
    _loadMala();
    // FamilyHandler().loadFamily();
  }

  Future<void> _loadMala() async {
    try {
      // _malaList = await widget._getMalas();
      _malaList = await _sharedPref.readList(Mala.key);
      final todayMala = _malaList.firstWhere((mala) => DateTimeHandler.isToday(mala.date));
      setState(() {
        _mala = todayMala;
      });
    } catch (error) {
      debugPrint('No malas found for today.\n$error');
      /*
      if (!mounted) return;
      showSnackBar(context, "No malas found for today.");
      */
    }
  }

  // Incrementing counter after click
  Future<void> _incrementCounter() async {
    if (_mala.japs == 0) {
      _malaList.add(_mala);
    }
    setState(() {
      if (DateTimeHandler.isToday(_mala.date)) {
        _mala.date = DateTimeHandler.today;
      }
      if (_selections.first) {
        _mala.count += 1;
        _mala.japs = _mala.count * Mala.japsPerMala;
      } else {
        _mala.japs += 1;
        _mala.count = _mala.japs ~/ Mala.japsPerMala;
      }
    });
    _sharedPref.saveList(Mala.key, _malaList);
    // widget._saveMalas(_malaList);
    if (!_selections.first && _mala.japs % Mala.japsPerMala == 0) {
      widget._playAlertSysSound();
    } else {
      widget._playBeep();
    }
  }

  Future<void> _decrementCounter() async {
    if (_mala.japs > 0) {
      widget._playBeep(false);
    }
    if (_selections.first && _mala.count > 0) {
      setState(() {
        _mala.count -= 1;
        _mala.japs = _mala.count * Mala.japsPerMala;
      });
    } else if (!_selections.first && _mala.japs > 0) {
      setState(() {
        _mala.count = _mala.japs ~/ Mala.japsPerMala;
        _mala.japs -= 1;
      });
    }
    if (_mala.japs == 0) {
      _malaList.remove(_mala);
    }
    _sharedPref.saveList(Mala.key, _malaList);
    // widget._saveMalas(_malaList);
  }

  Future<void> _resetCounter() async {
    if (_mala.japs > 0) {
      widget._playAlertSysSound();
      setState(() {
        _mala.count = 0;
        _mala.japs = 0;
      });
      _malaList.remove(_mala);
      _sharedPref.saveList(Mala.key, _malaList);
      // widget.deleteMalaByDate(_mala.date);
    }
  }

  Future<void> _restoreBackup() async {
    debugPrint("_restoreBackup");
    try {
      final files = await _googleDrive.downloadAppDataFolderFiles();
      const jsonFileHandler = JsonFileHandler();
      for (final file in files) {
        String path = '';
        final fileExtension = p.extension(file.path);
        final fileName = p.basename(file.path);
        debugPrint('Restoring $fileName.');
        if (fileName == GoogleDrive.malasFileName) {
          _restoreMalasBackup(file);
        } else if (fileExtension == '.json') {
          path = p.join(
            await jsonFileHandler.localPath(),
            fileName,
          );
        } else if (fileExtension == '.db') {
          path = await DBProvider.db.getDatabasePath();
        }
        if (path.isNotEmpty) {
          final newFile = File(path);
          await newFile.writeAsBytes(await file.readAsBytes());
        }
        await file.delete();
      }
      if (!mounted) return;
      await showAlertDialog(context, "Google Drive restore successful.");
    } catch (error) {
      debugPrint(error.toString());
      if (!mounted) return;
      showSnackBar(context, "Google Drive backup not available.\n$error");
    }
  }

  Future<void> _restoreMalasBackup(File file) async {
    try {
      debugPrint('_restoreMalasBackup');
      final malasString = await file.readAsString();
      final malasJson = json.decode(malasString) as List;
      final malas = malasJson.map((value) => Mala.fromJson(value)).toList();
      if (malas.isNotEmpty) {
        _malaList = malas;
        _sharedPref.saveList(Mala.key, malas);
        // widget._saveMalas(_malaList);

        try {
          final mala = malas.firstWhere((mala) => DateTimeHandler.isToday(mala.date));
          setState(() {
            _mala = mala;
          });
        } catch (error) {
          debugPrint('No malas found for today.\n$error');
        }

        debugPrint('Malas restored successfully.');
      } else {
        if (!mounted) return;
        showSnackBar(context, "Malas backup not available.");
      }
    } catch (error) {
      debugPrint(error.toString());
      if (!mounted) return;
      showSnackBar(context, "Malas backup not available.\n$error");
    }
  }

  Future<void> _restoreExcelBackup() async {
    debugPrint("_restoreExcelBackup");
    try {
      final malas = await widget._getMalasFromExcel();
      if (!mounted) return;
      if (malas.isEmpty) {
        showSnackBar(context, "No malas loaded from backup.");
      } else {
        _malaList.removeWhere((mala) => malas.contains(mala));
        malas.addAll(_malaList);
        _malaList = malas;
        _sharedPref.saveList(Mala.key, malas);
        // widget._saveMalas(_malaList);
        try {
          final mala = malas.firstWhere((mala) => DateTimeHandler.isToday(mala.date));
          setState(() {
            _mala = mala;
          });
        } catch(error) {
          debugPrint('No malas found for today.\n$error');
        }
        await showAlertDialog(context, "Excel restore successful.");
      }
    } catch (error) {
      if (!mounted) return;
      showSnackBar(context, "Excel restore failed.\n$error");
    }
  }

  Future<void> _saveBackup() async {
    try {
      final malasJson = json.encode(_malaList);
      debugPrint(malasJson);
      final tempDir = await getTemporaryDirectory();
      GoogleDrive.fileName = GoogleDrive.malasFileName;
      final file = File("${tempDir.path}/${GoogleDrive.fileName}");
      await file.writeAsString(malasJson);
      await _googleDrive.uploadFileToGoogleDrive(file);
      file.delete();
      debugPrint('Malas file uploaded successfully.');
    } catch (error) {
      if (!mounted) return;
      showSnackBar(context, error.toString());
    }

    try {
        final files = await const JsonFileHandler().files();
        for (final filePath in files) {
          debugPrint('File to upload with path: $filePath');
          final file = File(filePath);
          GoogleDrive.fileName = p.basename(filePath);
          await _googleDrive.uploadFileToGoogleDrive(file);
        }
        debugPrint('Family json files uploaded successfully.');

        final dbFilePath = await DBProvider.db.getDatabasePath();
        debugPrint('File to upload with path: $dbFilePath');
        final dbFile = File(dbFilePath);
        if (await dbFile.exists()) {
          GoogleDrive.fileName = p.basename(dbFilePath);
          await _googleDrive.uploadFileToGoogleDrive(dbFile);
          debugPrint('Database file uploaded successfully.');
        }
      } catch (error) {
        debugPrint(error.toString());
      }

      if (!mounted) return;
      await showAlertDialog(context, "Backup done successfully.");
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1992),
      //DateTime.now() - not to allow to choose before today.
      lastDate: DateTime.now(),
      //DateTime(2092) - to allow to choose future dates.
    );

    if (pickedDate != null) {
      setState(() {
        try {
          _mala = _malaList.firstWhere((mala) => DateUtils.isSameDay(mala.date, pickedDate));
        } catch (error) {
          _mala = Mala(pickedDate, 0, 0);
          debugPrint('No malas found for today.\n$error');
        }
      });
    }
  }

  String getJapsPerMala() {
    final currentMalaJaps = _mala.japs % Mala.japsPerMala;
    if (currentMalaJaps > 0) {
      return "${_mala.japs - currentMalaJaps} + $currentMalaJaps";
    } else {
      return "${_mala.japs}";
    }
  }

  Future<void> _handleExcelBackupSuccess() async {
    await showAlertDialog(context, 'Excel backup done successfully.');
  }

  void _handleExcelBackupFailure(String error) {
    showSnackBar(context, "Excel backup failed.\n$error");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            tooltip: 'Open Mala History',
            icon: const Icon(Icons.menu),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => MalaDataTablePage(malas: _malaList)));
            },
          ),
          IconButton(
            tooltip: 'Open My Family Tree',
            icon: const Icon(Icons.grass_sharp),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const FamilyListPage(
                    title: 'Famaily List',
                  ),
                ),
              );
            },
          ),
          /*
          IconButton(
            tooltip: 'Open My Family',
            icon: const Icon(Icons.family_restroom),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const HomePage(
                    title: 'Famaily',
                  ),
                ),
              );
            },
          ), */
          IconButton(
            tooltip: 'Open About',
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AboutPage()));
            },
          ),
          PopupMenuButton<Menu>(
            tooltip: "Google Drive",
            onSelected: (menu) async {
              switch (menu) {
                case Menu.backup:
                  showProgressIndicator(context, "Backup in Progress");
                  await _saveBackup();
                  break;
                case Menu.restore:
                  if (!context.mounted) return;
                  showProgressIndicator(context, "Restoring from Backup");
                  await _restoreBackup();
                  break;
                case Menu.backupExcel:
                  if (!context.mounted) return;
                  showProgressIndicator(context, "Excel Backup in Progress");
                  _malaList.sort((a, b) => a.compareTo(b));
                  final fileHandler = MalaJapExcelFileHandler(_malaList);
                  if (kIsWeb) {
                    await fileHandler.saveExcel(
                        _handleExcelBackupSuccess, _handleExcelBackupFailure);
                  } else if (Platform.isAndroid || Platform.isIOS) {
                    await fileHandler.createAndSaveExcelOnMobile(
                        _handleExcelBackupSuccess, _handleExcelBackupFailure);
                  } else {
                    await fileHandler.createAndSaveExcelOnDesktop(
                        _handleExcelBackupSuccess, _handleExcelBackupFailure);
                  }
                  break;
                case Menu.restoreExcel:
                  if (!context.mounted) return;
                  showProgressIndicator(context, "Restoring from Excel");
                  await _restoreExcelBackup();
                  break;
                case Menu.delete:
                  if (!context.mounted) return;
                  showProgressIndicator(context, "Deleting Backup");
                  try {
                    await _googleDrive.deleteAppDataFolderFiles();
                    if (!context.mounted) return;
                    await showAlertDialog(context,
                        "App data deleted successfully from Google Drive.");
                  } catch (error) {
                    if (!context.mounted) return;
                    showSnackBar(context, error.toString());
                  }
                  break;
                case Menu.signOut:
                  if (!context.mounted) return;
                  showProgressIndicator(context, "Signing Out");
                  await _googleDrive.signOut();
              }
              final user = await _googleDrive.getUser();
              setState(() {
                _user = user;
              });
              if (!context.mounted) return;
              hideProgressIndicator(context);
            },
            itemBuilder: (context) {
              return [
                const PopupMenuItem(
                  value: Menu.backupExcel,
                  child: Text(
                    'Backup Malas to Excel',
                  ),
                ),
                const PopupMenuItem(
                  value: Menu.restoreExcel,
                  child: Text(
                    'Restore Malas from Excel',
                  ),
                ),
                const PopupMenuItem(
                  value: Menu.backup,
                  child: Text(
                    'Backup to Google Drive',
                  ),
                ),
                const PopupMenuItem(
                  value: Menu.restore,
                  child: Text(
                    'Restore from Google Drive',
                  ),
                ),
                const PopupMenuItem(
                  value: Menu.delete,
                  child: Text(
                    'Delete Backup from Google Drive',
                  ),
                ),
                if (_user != null)
                  const PopupMenuItem(
                    value: Menu.signOut,
                    child: Text(
                      'Sign Out from Google Drive',
                    ),
                  ),
              ];
            },
          ),
        ],
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: viewportConstraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(height: 20),
                      if (_user?.name != null)
                        Text(
                          'Welcome ${_user?.name}',
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                      const SizedBox(height: 10),
                      Text(
                        'Your completed ${_selections.first ? 'malas' : 'japs'} on',
                        style: Theme.of(context).textTheme.headlineSmall,
                        // maxLines: 3,
                        // overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      TextButton.icon(
                        icon: const Icon(
                          Icons.calendar_today,
                          // color: Colors.black,
                          size: 18,
                        ),
                        label: Text(
                          DateTimeHandler.getString(_mala.date, DateTimeHandler.dateFormat),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        onPressed: _pickDate,
                      ),
                      const SizedBox(height: 10),
                      // if (!_selections.first) const SizedBox(height: 10),
                      Text(
                        '${_selections.first ? _mala.count : getJapsPerMala()}',
                        style: Theme.of(context).textTheme.displayMedium,
                        // style: _selections.first
                        //     ? Theme.of(context).textTheme.displayLarge
                        //     : Theme.of(context).textTheme.displayMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      // if (!_selections.first) const SizedBox(height: 10),
                      Text(
                        '${!_selections.first ? 'Malas' : 'Japs'}: ${!_selections.first ? _mala.count : _mala.japs}',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 20),
                      ToggleButtons(
                        onPressed: (int index) {
                          setState(() {
                            // The button that is tapped is set to true, and the others to false.
                            for (int i = 0; i < _selections.length; i++) {
                              _selections[i] = i == index;
                            }
                          });
                        },
                        borderRadius: const BorderRadius.all(Radius.circular(8)),
                        /*
                        selectedBorderColor: Colors.red[700],
                        selectedColor: Colors.white,
                        fillColor: Colors.red[200],
                        color: Colors.red[400],
                        */
                        constraints: const BoxConstraints(
                          minHeight: 40.0,
                          minWidth: 80.0,
                        ),
                        isSelected: _selections,
                        children: const [
                          Text('Mala'),
                          Text('Jap'),
                        ],
                      ),
                      Flexible(
                        child: SizedBox.expand(
                          child: Padding(
                            padding: const EdgeInsets.all(30),
                            child: ElevatedButton.icon(
                              icon: const Icon(
                                Icons.add,
                                // color: Colors.white,
                              ),
                              label: const Text(
                                'Add',
                                style: TextStyle(
                                  fontSize: 20,
                                  // color: Colors.white,
                                ),
                              ),
                              onPressed: _incrementCounter,
                              style: ButtonStyle(
                                shape: WidgetStateProperty.all(
                                  const CircleBorder(),
                                ),
                                padding: WidgetStateProperty.all(
                                  const EdgeInsets.all(20),
                                ),
                                /*
                                backgroundColor: WidgetStateProperty.all(
                                  Colors.red[200],
                                ), // <-- Button color
                                overlayColor:
                                    WidgetStateProperty.resolveWith<Color?>(
                                        (states) {
                                  if (states.contains(WidgetState.pressed)) {
                                    return Colors.blueGrey[700]; // <-- Splash color
                                  } else {
                                    return null;
                                  }
                                }),
                                */
                                minimumSize: WidgetStateProperty.all(
                                  const Size(150, 150),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            FloatingActionButton(
              heroTag: 1,
              onPressed: _decrementCounter,
              tooltip: 'Remove Mala or Jap',
              child: const Icon(Icons.remove),
            ),
            FloatingActionButton(
              heroTag: 4,
              onPressed: _resetCounter,
              tooltip: 'Reset Mala or Jap',
              child: const Icon(Icons.clear),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
