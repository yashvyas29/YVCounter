// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get title => 'YVCounter';

  @override
  String welcomeUser({required String name}) {
    return 'Welcome $name';
  }

  @override
  String get mala => 'Mala';

  @override
  String get jap => 'Jap';

  @override
  String completedForDate({required String malaJapString}) {
    return 'Your completed $malaJapString on';
  }

  @override
  String get add => 'Add';

  @override
  String get malaHistory => 'Mala History';

  @override
  String get date => 'Date';

  @override
  String get familyList => 'Family List';

  @override
  String get about => 'About';

  @override
  String get myName => 'Yash Vyas';

  @override
  String get aboutText =>
      'YVCounter app is created for solving a common scenario of counting malas or japs which is done by hindu religion pepole during meditation.\n\nIn Hinduism the jap mala is used to direct and count the recitation of mantras during meditation. It usually consists of 108 beads strung in a circle to represent the cyclic nature of life.';

  @override
  String get menu => 'Menu';

  @override
  String changeLanguageTo({required String language}) {
    return 'Change Language to $language';
  }

  @override
  String get english => 'English';

  @override
  String get hindi => 'Hindi';

  @override
  String get backupToExcel => 'Backup Mala to Excel';

  @override
  String get restoreFromExcel => 'Restore Mala from Excel';

  @override
  String get backupToGD => 'Backup to Google Drive';

  @override
  String get restoreFromGD => 'Restore from Google Drive';

  @override
  String get deleteBackupFromGD => 'Delete Backup from Google Drive';

  @override
  String get signOutFromGD => 'Sign Out from Google Drive';

  @override
  String get newFamily => 'New Family';

  @override
  String get vyasFamily => 'Vyas Family';

  @override
  String get kadvawatFamily => 'Kadvawat Family';

  @override
  String get dharmawatFamily => 'Dharmawat Family';

  @override
  String get excelSaveSuccessful => 'Excel saved successfully.';

  @override
  String get gdRestoreSuccessful => 'Google Drive restore successful.';

  @override
  String get excelRestoreSuccessful => 'Excel restore successful.';

  @override
  String get gdBackupSuccessful => 'Google Drive backup done successfully.';

  @override
  String get excelBackupSuccessful => 'Excel backup done successfully.';

  @override
  String get gdDataDeleteSuccessful =>
      'App data deleted successfully from Google Drive.';

  @override
  String get changingLanguage => 'Changing Language';

  @override
  String get backupInProgress => 'Backup in Progress';

  @override
  String get restoringFromBackup => 'Restoring from Backup';

  @override
  String get excelBackupInProgress => 'Excel Backup in Progress';

  @override
  String get restoringFromExcel => 'Restoring from Excel';

  @override
  String get deletingBackupFromGD => 'Deleting Backup from Google Drive';

  @override
  String get signingOutFromGD => 'Signing Out from Google Drive';

  @override
  String get malaNotAvailable => 'No mala available.';

  @override
  String get familyNotAvailable => 'No family available.';

  @override
  String get backupNotAvailable => 'Backup not available.';

  @override
  String get saveError => 'Save failed.';

  @override
  String get backupError => 'Backup failed.';

  @override
  String get restoreError => 'Restore failed.';

  @override
  String get deleteError => 'Delete failed.';

  @override
  String deleteConfirmation({required String name}) {
    return 'Are you sure you want to delete $name ?';
  }

  @override
  String get alert => 'Alert';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get renameToYourFamilyName => 'Rename to your family name.';

  @override
  String get added => 'added.';

  @override
  String get updated => 'updated.';

  @override
  String get deleted => 'deleted.';

  @override
  String get alreadyExists => 'already exists.';

  @override
  String get enterFamilyName => 'Enter family name.';

  @override
  String get enterParentsName => 'Enter parents name.';

  @override
  String get enterChildAndSpouseName =>
      'Enter child and his or her spouse name.';

  @override
  String get familyMemberDetails => 'Family Member Details';

  @override
  String get memberName => 'Member Name';

  @override
  String get spouseName => 'Spouse Name';

  @override
  String get image => 'image';

  @override
  String get commonError => 'Something went wrong, please try again later.';
}
