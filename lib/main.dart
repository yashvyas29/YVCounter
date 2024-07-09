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
    /*
    Listener(
      onPointerDown: (_) {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      children: [],
      );
      */
    return MaterialApp(
      title: 'YVCounter',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const MyHomePage(title: 'YVCounter'),
    );
  }
}
