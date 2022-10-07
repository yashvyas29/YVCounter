import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yv_counter/mala_data_table.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YVCounter',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'YVCounter'),
    );
  }
}

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
  final SharedPref sharedPref = SharedPref();
  String date = DateFormat(dateFormat).format(DateTime.now());
  int _counter = 0;
  List<Mala> _malaList = [];

  static const _japs = 108;
  static const dateFormat = 'yyyy-MM-dd';

  @override
  void initState() {
    super.initState();
    _loadMala();
  }

  _loadMala() async {
    final mala = Mala(date, 0, 0);
    try {
      final malaList = await sharedPref.readList(Mala.key);
      _malaList = malaList;
      if (malaList.last.date != DateFormat(dateFormat).format(DateTime.now())) {
        _malaList.add(mala);
      }
      setState(() {
        _counter = _malaList.last.count;
      });
    } catch (excepetion) {
      _malaList = [mala];
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Nothing found!"),
          duration: Duration(milliseconds: 2000)));
    }
  }

  _playBeep([bool success = true]) {
    if (Platform.isAndroid) {
      FlutterBeep.beep(success);
    } else {
      SystemSound.play(SystemSoundType.click);
    }
  }

  _playAlertSysSound() {
    if (Platform.isAndroid) {
      FlutterBeep.playSysSound(AndroidSoundIDs.TONE_CDMA_ABBR_ALERT);
    } else if (Platform.isIOS) {
      FlutterBeep.playSysSound(iOSSoundIDs.EndRecording);
    } else {
      SystemSound.play(SystemSoundType.alert);
    }
  }

  // Incrementing counter after click
  _incrementCounter() async {
    _playBeep();
    setState(() {
      ++_counter;
      _malaList.last.count = _counter;
      _malaList.last.japs = _counter * _japs;
      sharedPref.saveList(Mala.key, _malaList);
    });
  }

  _decrementCounter() async {
    _playBeep(false);
    if (_counter > 0) {
      setState(() {
        --_counter;
        _malaList.last.count = _counter;
        _malaList.last.japs = _counter * _japs;
        sharedPref.saveList(Mala.key, _malaList);
      });
    }
  }

  _resetCounter() async {
    _playAlertSysSound();
    setState(() {
      _counter = 0;
      _malaList.last.count = _counter;
      _malaList.last.japs = _counter;
      sharedPref.saveList(Mala.key, _malaList);
    });
  }

  _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1992),
        //DateTime.now() - not to allow to choose before today.
        lastDate: DateTime(2092));

    if (pickedDate != null) {
      setState(() {
        date = DateFormat(dateFormat).format(pickedDate);
      });
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
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => MalaDataTable(malas: _malaList)));
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 30),
            TextButton(
                onPressed: _pickDate,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Your completed malas on ',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const Icon(
                      Icons.calendar_today,
                      color: Colors.black,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      date,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                )),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            Text(
              'Japs: ${_counter * 108}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: SizedBox.expand(
                  child: FloatingActionButton.extended(
                    shape: const CircleBorder(),
                    icon: const Icon(Icons.add, size: 50),
                    label: const Text(
                      'Add Mala',
                      style: TextStyle(fontSize: 35),
                    ),
                    tooltip: 'Add Mala',
                    onPressed: _incrementCounter,
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
              onPressed: _decrementCounter,
              tooltip: 'Remove Mala',
              child: const Icon(Icons.remove),
            ),
            FloatingActionButton(
              onPressed: _resetCounter,
              tooltip: 'Reset Mala',
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

class Mala {
  String date;
  int count;
  int japs;
  bool selected = false;

  static String key = "Mala";

  Mala(this.date, this.count, this.japs);

  Mala.fromJson(Map<String, dynamic> json)
      : date = json['date'],
        count = json['count'],
        japs = json['japs'];

  Map<String, dynamic> toJson() => {
        'date': date,
        'count': count,
        'japs': japs,
      };
}

class SharedPref {
  read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(key);
    return value == null ? "" : json.decode(value);
  }

  save(String key, value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, json.encode(value));
  }

  readList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(key);
    return list == null
        ? []
        : list.map((value) => Mala.fromJson(json.decode(value))).toList();
  }

  saveList(String key, List<Mala> malas) async {
    final list = malas.map((mala) => json.encode(mala.toJson())).toList();
    debugPrint(list.join('\n'));
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(key, list);
  }

  remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
