import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_beep/flutter_beep.dart';
// import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  int _counter = 0;
  final String counterKey = 'counter';

  @override
  void initState() {
    super.initState();
    _loadCounter();
  }

  /*
  SharedPref sharedPref = SharedPref();
  Mala mala = Mala(DateTime.now(), 0, 0);

  _loadMala() async {
    try {
      Mala mala = Mala.fromJson(await sharedPref.read(Mala.key));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Loaded!"), duration: Duration(milliseconds: 500)));
      setState(() {
        mala = mala;
      });
    } catch (excepetion) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Nothing found!"),
          duration: Duration(milliseconds: 500)));
    }
  }

  _laoadDate() {
    debugPrint(DateTime.now().toIso8601String());
    final utcDate = DateTime.now().toUtc();
    final utcDateString = utcDate.toIso8601String();
    debugPrint(utcDateString);
    debugPrint(DateTime.parse(utcDateString).toLocal().toString());
    final utcDateShortString = DateFormat.yMd().format(utcDate);
    debugPrint(utcDateShortString);
    debugPrint(
        DateFormat.yMd().parseUTC(utcDateShortString).toLocal().toString());
  }
  */

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

  // Loading counter value on start
  Future<void> _loadCounter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _counter = (prefs.getInt(counterKey) ?? 0);
    });
  }

  // Incrementing counter after click
  Future<void> _incrementCounter() async {
    _playBeep();
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _counter = (prefs.getInt(counterKey) ?? 0) + 1;
      prefs.setInt(counterKey, _counter);
    });
  }

  Future<void> _decrementCounter() async {
    _playBeep(false);
    final prefs = await SharedPreferences.getInstance();
    if (_counter > 0) {
      setState(() {
        _counter = (prefs.getInt(counterKey) ?? 0) - 1;
        prefs.setInt(counterKey, _counter);
      });
    }
  }

  Future<void> _resetCounter() async {
    _playAlertSysSound();
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _counter = 0;
      prefs.setInt(counterKey, _counter);
    });
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
            Text(
              'Your completed malas:',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.displayLarge,
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
                      style: TextStyle(fontSize: 40),
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

/*
class Mala {
  DateTime date;
  int count;
  int japs;

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

  remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }
}
*/