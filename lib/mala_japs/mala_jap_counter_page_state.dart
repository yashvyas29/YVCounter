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
    _googleDrive.initializeGoogleSignIn().then((value) {
      _googleDrive.signInSilently().then((value) {
        _googleDrive.getUser().then((user) {
          setState(() {
            _user = user;
          });
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
      final todayMala = _malaList.firstWhere(
        (mala) => DateTimeHandler.isToday(mala.date),
      );
      setState(() {
        _mala = todayMala;
      });
    } catch (error) {
      debugPrint('No malas found for today.\n$error');
      /*
      if (!mounted) return;
      showSnackBar(context, AppLocalizations.of(context).noMalaAvailable);
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
          path = p.join(await jsonFileHandler.localPath(), fileName);
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
      await showAlertDialog(
        context,
        AppLocalizations.of(context).gdRestoreSuccessful,
      );
    } catch (error) {
      debugPrint(error.toString());
      if (!mounted) return;
      showSnackBar(
        context,
        "${AppLocalizations.of(context).backupNotAvailable}\n$error",
      );
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
          final mala = malas.firstWhere(
            (mala) => DateTimeHandler.isToday(mala.date),
          );
          setState(() {
            _mala = mala;
          });
        } catch (error) {
          debugPrint('No malas found for today.\n$error');
        }

        debugPrint('Malas restored successfully.');
      } else {
        if (!mounted) return;
        showSnackBar(context, AppLocalizations.of(context).backupNotAvailable);
      }
    } catch (error) {
      debugPrint(error.toString());
      if (!mounted) return;
      showSnackBar(
        context,
        "${AppLocalizations.of(context).backupNotAvailable}\n$error",
      );
    }
  }

  Future<void> _restoreExcelBackup() async {
    debugPrint("_restoreExcelBackup");
    try {
      final malas = await widget._getMalasFromExcel();
      if (!mounted) return;
      if (malas.isEmpty) {
        showSnackBar(context, AppLocalizations.of(context).malaNotAvailable);
      } else {
        _malaList.removeWhere((mala) => malas.contains(mala));
        malas.addAll(_malaList);
        _malaList = malas;
        _sharedPref.saveList(Mala.key, malas);
        // widget._saveMalas(_malaList);
        try {
          final mala = malas.firstWhere(
            (mala) => DateTimeHandler.isToday(mala.date),
          );
          setState(() {
            _mala = mala;
          });
        } catch (error) {
          debugPrint('No malas found for today.\n$error');
        }
        await showAlertDialog(
          context,
          AppLocalizations.of(context).excelRestoreSuccessful,
        );
      }
    } catch (error) {
      if (!mounted) return;
      showSnackBar(
        context,
        "${AppLocalizations.of(context).restoreError}\n$error",
      );
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
      showSnackBar(
        context,
        "${AppLocalizations.of(context).backupError}\n$error",
      );
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
    await showAlertDialog(
      context,
      AppLocalizations.of(context).gdBackupSuccessful,
    );
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
          _mala = _malaList.firstWhere(
            (mala) => DateUtils.isSameDay(mala.date, pickedDate),
          );
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
    await showAlertDialog(
      context,
      AppLocalizations.of(context).excelBackupSuccessful,
    );
  }

  void _handleExcelBackupFailure(String error) {
    showSnackBar(
      context,
      "${AppLocalizations.of(context).backupError}\n$error",
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    var language = Localizations.localeOf(context).toString();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).title),
        actions: [
          IconButton(
            tooltip: localizations.malaHistory,
            icon: const Icon(Icons.menu),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => MalaDataTablePage(malas: _malaList),
                ),
              );
            },
          ),
          IconButton(
            tooltip: localizations.familyList,
            icon: const Icon(Icons.grass_sharp),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      FamilyListPage(title: localizations.familyList),
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
                    title: 'Family',
                  ),
                ),
              );
            },
          ),
          */
          IconButton(
            tooltip: localizations.about,
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AboutPage()),
              );
            },
          ),
          Consumer<LocaleModel>(
            builder: (context, localeModel, child) {
              language = localeModel.locale.languageCode;
              final changeToLanguage = language == 'en' ? 'hi' : 'en';
              /*
              PopupMenuButton<LanguageMenu>(
                tooltip: localizations.menu,
                icon: const Icon(Icons.language),
                initialValue: language == 'hi' ? LanguageMenu.hindi : LanguageMenu.english,
                onSelected: (menu) async {
                  switch (menu) {
                    case LanguageMenu.english:
                      localeModel.set(const Locale('en'));
                      break;
                    case LanguageMenu.hindi:
                      localeModel.set(const Locale('hi'));
                      break;
                  }
                },
                itemBuilder: (context) {
                  return [
                    const PopupMenuItem(
                      value: LanguageMenu.english,
                      child: Text(
                        'English',
                      ),
                    ),
                    const PopupMenuItem(
                      value: LanguageMenu.hindi,
                      child: Text(
                        'हिन्दी',
                      ),
                    ),
                  ];
                },
              ),
              */
              return PopupMenuButton<Menu>(
                tooltip: localizations.menu,
                onSelected: (menu) async {
                  switch (menu) {
                    case Menu.language:
                      if (!mounted) return;
                      showProgressIndicator(
                        context,
                        localizations.changingLanguage,
                      );
                      localeModel.set(Locale(changeToLanguage));
                    case Menu.backup:
                      if (!mounted) return;
                      showProgressIndicator(
                        context,
                        localizations.backupInProgress,
                      );
                      await _saveBackup();
                      break;
                    case Menu.restore:
                      if (!mounted) return;
                      showProgressIndicator(
                        context,
                        localizations.restoringFromBackup,
                      );
                      await _restoreBackup();
                      break;
                    case Menu.backupExcel:
                      if (!mounted) return;
                      showProgressIndicator(
                        context,
                        localizations.excelBackupInProgress,
                      );
                      _malaList.sort((a, b) => a.compareTo(b));
                      final fileHandler = MalaJapExcelFileHandler(_malaList);
                      if (kIsWeb) {
                        await fileHandler.saveExcel(
                          _handleExcelBackupSuccess,
                          _handleExcelBackupFailure,
                        );
                      } else if (Platform.isAndroid || Platform.isIOS) {
                        await fileHandler.createAndSaveExcelOnMobile(
                          _handleExcelBackupSuccess,
                          _handleExcelBackupFailure,
                        );
                      } else {
                        await fileHandler.createAndSaveExcelOnDesktop(
                          _handleExcelBackupSuccess,
                          _handleExcelBackupFailure,
                        );
                      }
                      break;
                    case Menu.restoreExcel:
                      if (!mounted) return;
                      showProgressIndicator(
                        context,
                        localizations.restoringFromExcel,
                      );
                      await _restoreExcelBackup();
                      break;
                    case Menu.delete:
                      if (!mounted) return;
                      showProgressIndicator(
                        context,
                        localizations.deletingBackupFromGD,
                      );
                      try {
                        await _googleDrive.deleteAppDataFolderFiles();
                        if (!context.mounted) return;
                        await showAlertDialog(
                          context,
                          localizations.gdDataDeleteSuccessful,
                        );
                      } catch (error) {
                        if (!context.mounted) return;
                        showSnackBar(
                          context,
                          "${AppLocalizations.of(context).deleteError}\n$error",
                        );
                      }
                      break;
                    case Menu.signOut:
                      if (!mounted) return;
                      showProgressIndicator(
                        context,
                        localizations.signingOutFromGD,
                      );
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
                    PopupMenuItem(
                      value: Menu.language,
                      child: Text(
                        localizations.changeLanguageTo(
                          language: changeToLanguage == 'hi'
                              ? localizations.hindi
                              : localizations.english,
                        ),
                      ),
                    ),
                    PopupMenuItem(
                      value: Menu.backupExcel,
                      child: Text(localizations.backupToExcel),
                    ),
                    PopupMenuItem(
                      value: Menu.restoreExcel,
                      child: Text(localizations.restoreFromExcel),
                    ),
                    PopupMenuItem(
                      value: Menu.backup,
                      child: Text(localizations.backupToGD),
                    ),
                    PopupMenuItem(
                      value: Menu.restore,
                      child: Text(localizations.restoreFromGD),
                    ),
                    PopupMenuItem(
                      value: Menu.delete,
                      child: Text(localizations.deleteBackupFromGD),
                    ),
                    if (_user != null)
                      PopupMenuItem(
                        value: Menu.signOut,
                        child: Text(localizations.signOutFromGD),
                      ),
                  ];
                },
              );
            },
          ),
        ],
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
            final malaString = AppLocalizations.of(context).mala;
            final japString = AppLocalizations.of(context).jap;
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
                          localizations.welcomeUser(
                            name: _user?.name ?? 'User',
                          ),
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                      const SizedBox(height: 10),
                      Text(
                        AppLocalizations.of(context).completedForDate(
                          malaJapString: _selections.first
                              ? malaString
                              : japString,
                        ),
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
                          DateTimeHandler.getString(
                            _mala.date,
                            DateTimeHandler.dateFormat,
                          ),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        onPressed: _pickDate,
                      ),
                      const SizedBox(height: 10),
                      // if (!_selections.first) const SizedBox(height: 10),
                      Text(
                        '${_selections.first ? _mala.count : getJapsPerMala()}',
                        style: Theme.of(context).textTheme.displayMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      // if (!_selections.first) const SizedBox(height: 10),
                      Text(
                        '${!_selections.first ? malaString : japString}: ${!_selections.first ? _mala.count : _mala.japs}',
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
                        borderRadius: const BorderRadius.all(
                          Radius.circular(8),
                        ),
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
                        children: [Text(malaString), Text(japString)],
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
                              label: Text(
                                AppLocalizations.of(context).add,
                                style: const TextStyle(
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
