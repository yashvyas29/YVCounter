import 'package:flutter/material.dart';
import 'package:yv_counter/common/notification_service.dart';
import 'package:yv_counter/data_model/google_drive_model.dart';
import 'package:yv_counter/data_model/locale_model.dart';
import 'package:yv_counter/data_model/settings_model.dart';
/*
import 'package:isar/isar.dart';
import 'package:yv_counter/data_model/family_member_relation.dart';
import 'package:yv_counter/data_model/mala.dart';
*/
import 'package:yv_counter/mala_japs/mala_jap_counter_page.dart';
import 'package:provider/provider.dart';
import 'package:yv_counter/l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  /*
  await Isar.open([MalaSchema, FamilySchema, MemberSchema, RelationSchema],
      inspector: true);
      */
  await NotificationService.initialize();
  final localeModel = await LocaleModel.getInstance();
  final settingsModel = await SettingsModel.getInstance();
  final googleDriveModel = await GoogleDriveModel.getInstance();
  runApp(
    MyApp(
      localeModel: localeModel,
      settingsModel: settingsModel,
      googleDriveModel: googleDriveModel,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.localeModel,
    required this.settingsModel,
    required this.googleDriveModel,
  });

  final LocaleModel localeModel;
  final SettingsModel settingsModel;
  final GoogleDriveModel googleDriveModel;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LocaleModel>.value(value: localeModel),
        ChangeNotifierProvider<SettingsModel>.value(value: settingsModel),
        ChangeNotifierProvider<GoogleDriveModel>.value(value: googleDriveModel),
      ],
      child: Consumer2<LocaleModel, SettingsModel>(
        builder: (context, localeModel, settingsModel, child) => MaterialApp(
          onGenerateTitle: (context) => AppLocalizations.of(context).title,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: localeModel.locale,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: settingsModel.themeMode,
          home: const MyHomePage(),
        ),
      ),
    );
  }
}

/*
class LoadingPage extends StatefulWidget {
  const LoadingPage({required Key key}) : super(key: key);

  @override
  LoadingPageState createState() => LoadingPageState();
}

class LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
*/
