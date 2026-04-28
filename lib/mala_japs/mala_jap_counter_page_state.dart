part of 'mala_jap_counter_page.dart';

class _MyHomePageState extends State<MyHomePage> {
  late Mala _mala;
  List<Mala> _malaList = [];

  final List<bool> _selections = [true, false];

  @override
  void initState() {
    super.initState();
    _mala = Mala(DateTimeHandler.today, 0, 0);
    _loadMala();
    // FamilyHandler().loadFamily();
  }

  Future<void> _loadMala() async {
    try {
      _malaList = await AppDatabase.instance.getAllMalas();
      final todayMala = _malaList.firstWhere(
        (mala) => DateTimeHandler.isToday(mala.date),
      );
      setState(() {
        _mala = todayMala;
      });
    } catch (error) {
      dLog('No malas found for today.\n$error');
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
      final japsPerMala = Provider.of<SettingsModel>(
        context,
        listen: false,
      ).japsPerMala;
      if (_selections.first) {
        _mala.count += 1;
        _mala.japs = _mala.count * japsPerMala;
      } else {
        _mala.japs += 1;
        _mala.count = _mala.japs ~/ japsPerMala;
      }
    });
    AppDatabase.instance.upsertMala(_mala);
    final japsPerMala = Provider.of<SettingsModel>(
      context,
      listen: false,
    ).japsPerMala;
    if (!_selections.first && _mala.japs % japsPerMala == 0) {
      widget._playAlertSysSound();
    } else {
      widget._playBeep();
    }
  }

  Future<void> _decrementCounter() async {
    if (_mala.japs > 0) {
      widget._playBeep(false);
    }
    final japsPerMala = Provider.of<SettingsModel>(
      context,
      listen: false,
    ).japsPerMala;
    if (_selections.first && _mala.count > 0) {
      setState(() {
        _mala.count -= 1;
        _mala.japs = _mala.count * japsPerMala;
      });
    } else if (!_selections.first && _mala.japs > 0) {
      setState(() {
        _mala.count = _mala.japs ~/ japsPerMala;
        _mala.japs -= 1;
      });
    }
    if (_mala.japs == 0) {
      _malaList.remove(_mala);
      AppDatabase.instance.deleteMalaByDate(_mala.date);
    } else {
      AppDatabase.instance.upsertMala(_mala);
    }
  }

  Future<void> _resetCounter() async {
    if (_mala.japs == 0) return;

    final ctx = context;
    final localizations = AppLocalizations.of(ctx);
    // ignore: use_build_context_synchronously
    await showDeleteConfirmationDialog(
      ctx,
      localizations.resetConfirmation(
        date: DateTimeHandler.getString(_mala.date, DateTimeHandler.dateFormat),
      ),
      () async {
        if (!mounted) return;
        widget._playAlertSysSound();
        setState(() {
          _mala.count = 0;
          _mala.japs = 0;
        });
        _malaList.remove(_mala);
        await AppDatabase.instance.deleteMalaByDate(_mala.date);
        // ignore: use_build_context_synchronously
        Navigator.of(ctx).pop();
      },
    );
  }

  Future<void> _restoreBackup() async {
    dLog("_restoreBackup");
    final drive = context.read<GoogleDriveModel>().drive;
    try {
      final files = await drive.downloadAppDataFolderFiles();
      const jsonFileHandler = JsonFileHandler();
      for (final file in files) {
        String path = '';
        final fileExtension = p.extension(file.path);
        final fileName = p.basename(file.path);
        dLog('Restoring $fileName.');
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
      dLog(error.toString());
      if (!mounted) return;
      showSnackBar(
        context,
        "${AppLocalizations.of(context).backupNotAvailable}\n$error",
      );
    }
  }

  Future<void> _restoreMalasBackup(File file) async {
    try {
      dLog('_restoreMalasBackup');
      final malasString = await file.readAsString();
      final malasJson = json.decode(malasString) as List;
      final malas = malasJson.map((value) => Mala.fromJson(value)).toList();
      if (malas.isNotEmpty) {
        _malaList = malas;
        for (final mala in malas) {
          await AppDatabase.instance.upsertMala(mala);
        }

        try {
          final mala = malas.firstWhere(
            (mala) => DateTimeHandler.isToday(mala.date),
          );
          setState(() {
            _mala = mala;
          });
        } catch (error) {
          dLog('No malas found for today.\n$error');
        }

        dLog('Malas restored successfully.');
      } else {
        if (!mounted) return;
        showSnackBar(context, AppLocalizations.of(context).backupNotAvailable);
      }
    } catch (error) {
      dLog(error.toString());
      if (!mounted) return;
      showSnackBar(
        context,
        "${AppLocalizations.of(context).backupNotAvailable}\n$error",
      );
    }
  }

  Future<void> _restoreExcelBackup() async {
    dLog("_restoreExcelBackup");
    try {
      final malas = await widget._getMalasFromExcel();
      if (!mounted) return;
      if (malas.isEmpty) {
        showSnackBar(context, AppLocalizations.of(context).malaNotAvailable);
      } else {
        _malaList.removeWhere((mala) => malas.contains(mala));
        malas.addAll(_malaList);
        _malaList = malas;
        for (final mala in malas) {
          await AppDatabase.instance.upsertMala(mala);
        }
        try {
          final mala = malas.firstWhere(
            (mala) => DateTimeHandler.isToday(mala.date),
          );
          setState(() {
            _mala = mala;
          });
        } catch (error) {
          dLog('No malas found for today.\n$error');
        }
        if (!mounted) return;
        await showAlertDialog(
          // ignore: use_build_context_synchronously
          context,
          // ignore: use_build_context_synchronously
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
    final drive = context.read<GoogleDriveModel>().drive;
    try {
      final freshMalas = await AppDatabase.instance.getAllMalas();
      final malasJson = json.encode(freshMalas);
      dLog(malasJson);
      final tempDir = await getTemporaryDirectory();
      GoogleDrive.fileName = GoogleDrive.malasFileName;
      final file = File("${tempDir.path}/${GoogleDrive.fileName}");
      await file.writeAsString(malasJson);
      await drive.uploadFileToGoogleDrive(file);
      file.delete();
      dLog('Malas file uploaded successfully.');
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
        dLog('File to upload with path: $filePath');
        final file = File(filePath);
        GoogleDrive.fileName = p.basename(filePath);
        await drive.uploadFileToGoogleDrive(file);
      }
      dLog('Family json files uploaded successfully.');

      final dbFilePath = await DBProvider.db.getDatabasePath();
      dLog('File to upload with path: $dbFilePath');
      final dbFile = File(dbFilePath);
      if (await dbFile.exists()) {
        GoogleDrive.fileName = p.basename(dbFilePath);
        await drive.uploadFileToGoogleDrive(dbFile);
        dLog('Database file uploaded successfully.');
      }
    } catch (error) {
      dLog(error.toString());
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
          dLog('No malas found for today.\n$error');
        }
      });
    }
  }

  String getJapsPerMala(int japsPerMala) {
    final currentMalaJaps = _mala.japs % japsPerMala;
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
    final driveModel = context.watch<GoogleDriveModel>();
    var language = Localizations.localeOf(context).toString();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).title),
        actions: [
          IconButton(
            tooltip: localizations.malaProgress,
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
            tooltip: localizations.settings,
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
          */
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
                    case Menu.settings:
                      if (!mounted) return;
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SettingsPage(),
                        ),
                      );
                      break;
                    case Menu.language:
                      if (!mounted) return;
                      showProgressIndicator(
                        context,
                        localizations.changingLanguage,
                      );
                      localeModel.set(Locale(changeToLanguage));
                      if (!context.mounted) return;
                      hideProgressIndicator(context);
                      break;
                    case Menu.signIn:
                      if (!mounted) return;
                      showProgressIndicator(
                        context,
                        localizations.signInToGoogleDrive,
                      );
                      await context.read<GoogleDriveModel>().signIn();
                      if (!context.mounted) return;
                      hideProgressIndicator(context);
                      break;
                    case Menu.backup:
                      if (!mounted) return;
                      if (!context.read<GoogleDriveModel>().isSignedIn) {
                        showSnackBar(
                          context,
                          '${localizations.signInToGoogleDrive} first',
                        );
                        break;
                      }
                      showProgressIndicator(
                        context,
                        localizations.backupInProgress,
                      );
                      await _saveBackup();
                      if (!context.mounted) return;
                      hideProgressIndicator(context);
                      break;
                    case Menu.restore:
                      if (!mounted) return;
                      if (!context.read<GoogleDriveModel>().isSignedIn) {
                        showSnackBar(
                          context,
                          '${localizations.signInToGoogleDrive} first',
                        );
                        break;
                      }
                      showProgressIndicator(
                        context,
                        localizations.restoringFromBackup,
                      );
                      await _restoreBackup();
                      if (!context.mounted) return;
                      hideProgressIndicator(context);
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
                      } else {
                        await fileHandler.createAndSaveExcelOnDesktop(
                          _handleExcelBackupSuccess,
                          _handleExcelBackupFailure,
                        );
                      }
                      if (!context.mounted) return;
                      hideProgressIndicator(context);
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
                      if (!context.read<GoogleDriveModel>().isSignedIn) {
                        showSnackBar(
                          context,
                          '${localizations.signInToGoogleDrive} first',
                        );
                        break;
                      }
                      showProgressIndicator(
                        context,
                        localizations.deletingBackupFromGD,
                      );
                      try {
                        await context
                            .read<GoogleDriveModel>()
                            .drive
                            .deleteAppDataFolderFiles();
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
                      await context.read<GoogleDriveModel>().signOut();
                      if (!context.mounted) return;
                      hideProgressIndicator(context);
                      break;
                  }
                },
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      value: Menu.settings,
                      child: Text(localizations.settings),
                    ),
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
                    if (!driveModel.isSignedIn)
                      PopupMenuItem(
                        value: Menu.signIn,
                        child: Text(localizations.signInToGoogleDrive),
                      ),
                    if (driveModel.isSignedIn)
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
            final settings = Provider.of<SettingsModel>(context);
            final malaString = settings.getLocalizedPrimaryLabel(context);
            final japString = settings.getLocalizedSecondaryLabel(context);
            final japsPerMala = settings.japsPerMala;
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
                      if (driveModel.currentUser?.name != null)
                        Text(
                          localizations.welcomeUser(
                            name: driveModel.currentUser?.name ?? 'User',
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
                        '${_selections.first ? _mala.count : getJapsPerMala(japsPerMala)}',
                        style: Theme.of(context).textTheme.displayMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      // if (!_selections.first) const SizedBox(height: 10),
                      Text(
                        '${!_selections.first ? malaString : japString}: ${!_selections.first ? _mala.count : _mala.japs}',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      if (settings.dailyMalaTarget > 0) ...[
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: LinearProgressIndicator(
                            value: (_mala.count / settings.dailyMalaTarget)
                                .clamp(0.0, 1.0),
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_mala.count} / ${settings.dailyMalaTarget} $malaString',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
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
      floatingActionButton: _mala.japs > 0
          ? Padding(
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
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
