import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:intl/intl.dart';
import 'package:yv_counter/about_page.dart';
import 'package:yv_counter/mala.dart';
import 'package:yv_counter/mala_data_table_page.dart';
import 'package:yv_counter/shared_pref.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Mala _mala;
  List<Mala> _malaList = [];

  final SharedPref sharedPref = SharedPref();
  final String today = DateFormat(dateFormat).format(DateTime.now());
  final List<bool> _selections = [true, false];

  static const _japsPerMala = 108;
  static const dateFormat = 'yyyy-MM-dd';

  @override
  void initState() {
    super.initState();
    _mala = Mala(today, 0, 0);
    _loadMala();
  }

  Future<void> _loadMala() async {
    try {
      final malaList = await sharedPref.readList(Mala.key);
      _malaList = malaList;
      final todayMala =
          malaList.where((mala) => mala.date == today).toList().first;
      setState(() {
        _mala = todayMala;
      });
    } catch (excepetion) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Nothing found!"),
          duration: Duration(milliseconds: 2000)));
    }
  }

  void _playBeep([bool success = true]) {
    if (Platform.isAndroid) {
      FlutterBeep.beep(success);
    } else {
      SystemSound.play(SystemSoundType.click);
    }
  }

  void _playAlertSysSound() {
    if (Platform.isAndroid) {
      FlutterBeep.playSysSound(AndroidSoundIDs.TONE_CDMA_ABBR_ALERT);
    } else {
      SystemSound.play(SystemSoundType.alert);
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
          ? _mala.japs = _mala.count * _japsPerMala
          : _mala.count = _mala.japs ~/ _japsPerMala;
    });
    sharedPref.saveList(Mala.key, _malaList);
    if (!_selections.first && _mala.japs % _japsPerMala == 0) {
      _playAlertSysSound();
    } else {
      _playBeep();
    }
  }

  Future<void> _decrementCounter() async {
    if (_mala.japs > 0) {
      _playBeep(false);
    }
    if (_selections.first && _mala.count > 0) {
      setState(() {
        _mala.count -= 1;
        _mala.japs = _mala.count * _japsPerMala;
      });
    } else if (!_selections.first && _mala.japs > 0) {
      setState(() {
        _mala.count = _mala.japs ~/ _japsPerMala;
        _mala.japs -= 1;
      });
    }
    if (_mala.japs == 0) {
      _malaList.remove(_mala);
    }
    sharedPref.saveList(Mala.key, _malaList);
  }

  Future<void> _resetCounter() async {
    if (_mala.japs > 0) {
      _playAlertSysSound();
      setState(() {
        _mala.count = 0;
        _mala.japs = 0;
      });
      _malaList.remove(_mala);
      sharedPref.saveList(Mala.key, _malaList);
    }
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
          _mala = _malaList.where((mala) => mala.date == date).toList().first;
        } catch (excepetion) {
          _mala = Mala(date, 0, 0);
        }
      });
    }
  }

  String getJapsPerMala() {
    final currentMalaJaps = _mala.japs % _japsPerMala;
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
              final malas = await sharedPref.readList(Mala.key);
              if (!mounted) return;
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => MalaDataTablePage(malas: malas)));
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
        ],
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
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
            const SizedBox(height: 30),
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
              borderRadius: const BorderRadius.all(Radius.circular(8)),
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
                    label: const Text('Add', style: TextStyle(fontSize: 20)),
                    onPressed: _incrementCounter,
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(const CircleBorder()),
                      padding:
                          MaterialStateProperty.all(const EdgeInsets.all(20)),
                      backgroundColor: MaterialStateProperty.all(
                          Colors.blue), // <-- Button color
                      overlayColor:
                          MaterialStateProperty.resolveWith<Color?>((states) {
                        if (states.contains(MaterialState.pressed)) {
                          return Colors.red; // <-- Splash color
                        } else {
                          return null;
                        }
                      }),
                    ),
                  ),
                ),
              ),
            ),
          ],
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
              heroTag: 2,
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
