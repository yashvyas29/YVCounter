import 'package:flutter/material.dart';
/*
import 'package:isar/isar.dart';
import 'package:yv_counter/data_model/family_member_relation.dart';
import 'package:yv_counter/data_model/mala.dart';
*/
import 'package:yv_counter/mala_japs/mala_jap_counter_page.dart';

Future<void> main() async {
  /*
  await Isar.open([MalaSchema, FamilySchema, MemberSchema, RelationSchema],
      inspector: true);
      */
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return
        /*
    Listener(
      onPointerDown: (_) {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child:
      */
        MaterialApp(
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
        scrollbarTheme: ScrollbarThemeData(
          thumbVisibility: MaterialStateProperty.all<bool>(true),
        ),
      ),
      home: const MyHomePage(title: 'YVCounter'),
    );
    // );
  }
}
