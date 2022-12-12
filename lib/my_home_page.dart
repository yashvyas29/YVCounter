import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yv_counter/about_page.dart';
import 'package:yv_counter/google_drive.dart';
import 'package:yv_counter/mala.dart';
import 'package:yv_counter/mala_data_table_page.dart';
import 'package:yv_counter/shared_pref.dart';
import 'package:yv_counter/user.dart';

part 'my_home_page_state.dart';

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

// This is the type used by the popup menu below.
enum Menu { signIn, backup, restore, delete, signOut }
