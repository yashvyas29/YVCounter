import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
  ];

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'YVCounter'**
  String get title;

  /// No description provided for @welcomeUser.
  ///
  /// In en, this message translates to:
  /// **'Welcome {name}'**
  String welcomeUser({required String name});

  /// No description provided for @mala.
  ///
  /// In en, this message translates to:
  /// **'Mala'**
  String get mala;

  /// No description provided for @jap.
  ///
  /// In en, this message translates to:
  /// **'Jap'**
  String get jap;

  /// No description provided for @completedForDate.
  ///
  /// In en, this message translates to:
  /// **'Your completed {malaJapString} on'**
  String completedForDate({required String malaJapString});

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @malaHistory.
  ///
  /// In en, this message translates to:
  /// **'Mala History'**
  String get malaHistory;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @familyList.
  ///
  /// In en, this message translates to:
  /// **'Family List'**
  String get familyList;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @myName.
  ///
  /// In en, this message translates to:
  /// **'Yash Vyas'**
  String get myName;

  /// No description provided for @aboutText.
  ///
  /// In en, this message translates to:
  /// **'YVCounter app is created for solving a common scenario of counting malas or japs which is done by hindu religion pepole during meditation.\n\nIn Hinduism the jap mala is used to direct and count the recitation of mantras during meditation. It usually consists of 108 beads strung in a circle to represent the cyclic nature of life.'**
  String get aboutText;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @changeLanguageTo.
  ///
  /// In en, this message translates to:
  /// **'Change Language to {language}'**
  String changeLanguageTo({required String language});

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get hindi;

  /// No description provided for @backupToExcel.
  ///
  /// In en, this message translates to:
  /// **'Backup Mala to Excel'**
  String get backupToExcel;

  /// No description provided for @restoreFromExcel.
  ///
  /// In en, this message translates to:
  /// **'Restore Mala from Excel'**
  String get restoreFromExcel;

  /// No description provided for @backupToGD.
  ///
  /// In en, this message translates to:
  /// **'Backup to Google Drive'**
  String get backupToGD;

  /// No description provided for @restoreFromGD.
  ///
  /// In en, this message translates to:
  /// **'Restore from Google Drive'**
  String get restoreFromGD;

  /// No description provided for @deleteBackupFromGD.
  ///
  /// In en, this message translates to:
  /// **'Delete Backup from Google Drive'**
  String get deleteBackupFromGD;

  /// No description provided for @signOutFromGD.
  ///
  /// In en, this message translates to:
  /// **'Sign Out from Google Drive'**
  String get signOutFromGD;

  /// No description provided for @newFamily.
  ///
  /// In en, this message translates to:
  /// **'New Family'**
  String get newFamily;

  /// No description provided for @vyasFamily.
  ///
  /// In en, this message translates to:
  /// **'Vyas Family'**
  String get vyasFamily;

  /// No description provided for @kadvawatFamily.
  ///
  /// In en, this message translates to:
  /// **'Kadvawat Family'**
  String get kadvawatFamily;

  /// No description provided for @dharmawatFamily.
  ///
  /// In en, this message translates to:
  /// **'Dharmawat Family'**
  String get dharmawatFamily;

  /// No description provided for @excelSaveSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Excel saved successfully.'**
  String get excelSaveSuccessful;

  /// No description provided for @gdRestoreSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Google Drive restore successful.'**
  String get gdRestoreSuccessful;

  /// No description provided for @excelRestoreSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Excel restore successful.'**
  String get excelRestoreSuccessful;

  /// No description provided for @gdBackupSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Google Drive backup done successfully.'**
  String get gdBackupSuccessful;

  /// No description provided for @excelBackupSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Excel backup done successfully.'**
  String get excelBackupSuccessful;

  /// No description provided for @gdDataDeleteSuccessful.
  ///
  /// In en, this message translates to:
  /// **'App data deleted successfully from Google Drive.'**
  String get gdDataDeleteSuccessful;

  /// No description provided for @changingLanguage.
  ///
  /// In en, this message translates to:
  /// **'Changing Language'**
  String get changingLanguage;

  /// No description provided for @backupInProgress.
  ///
  /// In en, this message translates to:
  /// **'Backup in Progress'**
  String get backupInProgress;

  /// No description provided for @restoringFromBackup.
  ///
  /// In en, this message translates to:
  /// **'Restoring from Backup'**
  String get restoringFromBackup;

  /// No description provided for @excelBackupInProgress.
  ///
  /// In en, this message translates to:
  /// **'Excel Backup in Progress'**
  String get excelBackupInProgress;

  /// No description provided for @restoringFromExcel.
  ///
  /// In en, this message translates to:
  /// **'Restoring from Excel'**
  String get restoringFromExcel;

  /// No description provided for @deletingBackupFromGD.
  ///
  /// In en, this message translates to:
  /// **'Deleting Backup from Google Drive'**
  String get deletingBackupFromGD;

  /// No description provided for @signingOutFromGD.
  ///
  /// In en, this message translates to:
  /// **'Signing Out from Google Drive'**
  String get signingOutFromGD;

  /// No description provided for @malaNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'No mala available.'**
  String get malaNotAvailable;

  /// No description provided for @familyNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'No family available.'**
  String get familyNotAvailable;

  /// No description provided for @backupNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Backup not available.'**
  String get backupNotAvailable;

  /// No description provided for @saveError.
  ///
  /// In en, this message translates to:
  /// **'Save failed.'**
  String get saveError;

  /// No description provided for @backupError.
  ///
  /// In en, this message translates to:
  /// **'Backup failed.'**
  String get backupError;

  /// No description provided for @restoreError.
  ///
  /// In en, this message translates to:
  /// **'Restore failed.'**
  String get restoreError;

  /// No description provided for @deleteError.
  ///
  /// In en, this message translates to:
  /// **'Delete failed.'**
  String get deleteError;

  /// No description provided for @deleteConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {name} ?'**
  String deleteConfirmation({required String name});

  /// No description provided for @alert.
  ///
  /// In en, this message translates to:
  /// **'Alert'**
  String get alert;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @renameToYourFamilyName.
  ///
  /// In en, this message translates to:
  /// **'Rename to your family name.'**
  String get renameToYourFamilyName;

  /// No description provided for @added.
  ///
  /// In en, this message translates to:
  /// **'added.'**
  String get added;

  /// No description provided for @updated.
  ///
  /// In en, this message translates to:
  /// **'updated.'**
  String get updated;

  /// No description provided for @deleted.
  ///
  /// In en, this message translates to:
  /// **'deleted.'**
  String get deleted;

  /// No description provided for @alreadyExists.
  ///
  /// In en, this message translates to:
  /// **'already exists.'**
  String get alreadyExists;

  /// No description provided for @enterFamilyName.
  ///
  /// In en, this message translates to:
  /// **'Enter family name.'**
  String get enterFamilyName;

  /// No description provided for @enterParentsName.
  ///
  /// In en, this message translates to:
  /// **'Enter parents name.'**
  String get enterParentsName;

  /// No description provided for @enterChildAndSpouseName.
  ///
  /// In en, this message translates to:
  /// **'Enter child and his or her spouse name.'**
  String get enterChildAndSpouseName;

  /// No description provided for @familyMemberDetails.
  ///
  /// In en, this message translates to:
  /// **'Family Member Details'**
  String get familyMemberDetails;

  /// No description provided for @memberName.
  ///
  /// In en, this message translates to:
  /// **'Member Name'**
  String get memberName;

  /// No description provided for @spouseName.
  ///
  /// In en, this message translates to:
  /// **'Spouse Name'**
  String get spouseName;

  /// No description provided for @image.
  ///
  /// In en, this message translates to:
  /// **'image'**
  String get image;

  /// No description provided for @commonError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong, please try again later.'**
  String get commonError;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
