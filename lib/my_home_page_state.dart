part of 'my_home_page.dart';

class _MyHomePageState extends State<MyHomePage> {
  late Mala _mala;
  List<Mala> _malaList = [];
  User? _user;

  final GoogleDrive _googleDrive = GoogleDrive();
  final SharedPref _sharedPref = SharedPref();
  final String _today = DateFormat(dateFormat).format(DateTime.now());
  final List<bool> _selections = [true, false];

  static const dateFormat = 'yyyy-MM-dd';

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
    _mala = Mala(_today, 0, 0);
    _loadMala();
  }

  Future<void> _loadMala() async {
    try {
      _malaList = await _sharedPref.readList(Mala.key);
      final todayMala = _malaList.firstWhere((mala) => mala.date == _today);
      setState(() {
        _mala = todayMala;
      });
    } catch (error) {
      _showSnackBar("Nothing found!");
    }
  }

  // Incrementing counter after click
  Future<void> _incrementCounter() async {
    if (_mala.japs == 0) {
      _malaList.add(_mala);
    }
    setState(() {
      _selections.first ? _mala.count += 1 : _mala.japs += 1;
      _selections.first
          ? _mala.japs = _mala.count * Mala.japsPerMala
          : _mala.count = _mala.japs ~/ Mala.japsPerMala;
    });
    _sharedPref.saveList(Mala.key, _malaList);
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
    }
  }

  Future<void> _restoreBackup() async {
    debugPrint("_restoreBackup");
    final file = await _googleDrive.downloadGoogleDriveFile();
    if (file != null) {
      final malasString = await file.readAsString();
      final malasJson = json.decode(malasString) as List;
      final malas = malasJson.map((value) => Mala.fromJson(value)).toList();
      if (malas.isNotEmpty) {
        _malaList = malas;
        _sharedPref.saveList(Mala.key, malas);
        try {
          final mala = malas.firstWhere((mala) => mala.date == _today);
          setState(() {
            _mala = mala;
          });
        } catch (error) {
          _showSnackBar("No mala available for today in backup.");
        }
      } else {
        _showSnackBar("No backup available.");
      }
    }
  }

  Future<void> _restoreExcelBackup() async {
    debugPrint("_restoreExcelBackup");
    final malas = await widget._getMalasFromExcel();
    if (malas.isEmpty) {
      _showSnackBar("No malas loaded from backup.");
    } else {
      _malaList.removeWhere((mala) => malas.contains(mala));
      malas.addAll(_malaList);
      _malaList = malas;
      _sharedPref.saveList(Mala.key, malas);
      try {
        final mala = malas.firstWhere((mala) => mala.date == _today);
        setState(() {
          _mala = mala;
        });
      } catch (error) {
        _showSnackBar("No mala available for today in backup.");
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message), duration: const Duration(milliseconds: 2000)));
  }

  void _showProgressIndicator(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                Text(message),
              ],
            ),
          ),
        );
      },
    );
  }

  void _hideProgressIndicator() {
    Navigator.pop(context);
  }

  Future<void> _saveBackup() async {
    final malasJson = json.encode(_malaList);
    debugPrint(malasJson);
    final tempDir = await getTemporaryDirectory();
    final file = File("${tempDir.path}/malas");
    await file.writeAsString(malasJson);
    await _googleDrive.uploadFileToGoogleDrive(file);
    file.delete();
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
        final date = DateFormat(dateFormat).format(pickedDate);
        try {
          _mala = _malaList.firstWhere((mala) => mala.date == date);
        } catch (excepetion) {
          _mala = Mala(date, 0, 0);
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

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        actions: [
          IconButton(
            tooltip: 'Open Mala History',
            icon: const Icon(Icons.menu),
            onPressed: () async {
              final malas = await _sharedPref.readList(Mala.key);
              if (!mounted) return;
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => MalaDataTablePage(malas: malas)));
            },
          ),
          IconButton(
            tooltip: 'Open My Family Tree',
            icon: const Icon(Icons.grass_sharp),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const FamilyTreePage(
                        title: "Vanshavali",
                      )));
            },
          ),
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
                case Menu.signIn:
                  await _googleDrive.signIn();
                  break;
                case Menu.backup:
                  _showProgressIndicator("Backup in Progress");
                  await _saveBackup();
                  _hideProgressIndicator();
                  break;
                case Menu.restore:
                  _showProgressIndicator("Restoring from Backup");
                  await _restoreBackup();
                  _hideProgressIndicator();
                  break;
                case Menu.restoreExcel:
                  _showProgressIndicator("Restoring from Excel");
                  await _restoreExcelBackup();
                  _hideProgressIndicator();
                  break;
                case Menu.delete:
                  _showProgressIndicator("Deleting Backup");
                  await _googleDrive.deleteAppDataFolderFiles();
                  _hideProgressIndicator();
                  break;
                case Menu.signOut:
                  _showProgressIndicator("Signing Out");
                  await _googleDrive.signOut();
                  _hideProgressIndicator();
              }
              final user = await _googleDrive.getUser();
              setState(() {
                _user = user;
              });
            },
            itemBuilder: (context) {
              return [
                /*
                if (_user == null)
                  const PopupMenuItem(
                    value: Menu.signIn,
                    child: Text(
                      'Sign In to Google Drive',
                    ),
                  ),
                  */
                const PopupMenuItem(
                  value: Menu.restoreExcel,
                  child: Text(
                    'Restore from Excel',
                  ),
                ),
                const PopupMenuItem(
                  value: Menu.restore,
                  child: Text(
                    'Restore from Google Drive',
                  ),
                ),
                const PopupMenuItem(
                  value: Menu.backup,
                  child: Text(
                    'Backup to Google Drive',
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
                    // Column is also a layout widget. It takes a list of children and
                    // arranges them vertically. By default, it sizes itself to fit its
                    // children horizontally, and tries to be as tall as its parent.
                    //
                    // Invoke "debug painting" (press "p" in the console, choose the
                    // "Toggle Debug Paint" action from the Flutter Inspector in Android
                    // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
                    // to see the wireframe for each widget.
                    //
                    // Column has various properties to control how it sizes itself and
                    // how it positions its children. Here we use mainAxisAlignment to
                    // center the children vertically; the main axis here is the vertical
                    // axis because Columns are vertical (the cross axis would be
                    // horizontal).
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
                          color: Colors.black,
                          size: 18,
                        ),
                        label: Text(
                          _mala.date,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        onPressed: _pickDate,
                      ),
                      Text(
                        '${_selections.first ? _mala.count : getJapsPerMala()}',
                        style: _selections.first
                            ? Theme.of(context).textTheme.displayLarge
                            : Theme.of(context).textTheme.displayMedium,
                        textAlign: TextAlign.center,
                      ),
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
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
                        selectedBorderColor: Colors.red[700],
                        selectedColor: Colors.white,
                        fillColor: Colors.red[200],
                        color: Colors.red[400],
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
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 50),
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.add, color: Colors.white),
                              label: const Text('Add',
                                  style: TextStyle(fontSize: 20)),
                              onPressed: _incrementCounter,
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all(
                                    const CircleBorder()),
                                padding: MaterialStateProperty.all(
                                    const EdgeInsets.all(20)),
                                backgroundColor: MaterialStateProperty.all(
                                    Colors.blue), // <-- Button color
                                overlayColor:
                                    MaterialStateProperty.resolveWith<Color?>(
                                        (states) {
                                  if (states.contains(MaterialState.pressed)) {
                                    return Colors.red; // <-- Splash color
                                  } else {
                                    return null;
                                  }
                                }),
                                minimumSize: MaterialStateProperty.all(
                                    const Size(150, 150)),
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
