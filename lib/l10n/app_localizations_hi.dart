// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get title => 'माला गणक';

  @override
  String welcomeUser({required String name}) {
    return 'स्वागत है $name जी';
  }

  @override
  String get mala => 'माला';

  @override
  String get jap => 'जप';

  @override
  String completedForDate({required String malaJapString}) {
    return 'आपकी पूर्ण की गई $malaJapString';
  }

  @override
  String get add => 'जोड़े';

  @override
  String get malaHistory => 'माला इतिहास';

  @override
  String get date => 'दिनांक';

  @override
  String get familyList => 'परिवार सूची';

  @override
  String get about => 'जानकारी';

  @override
  String get myName => 'यश व्यास';

  @override
  String get aboutText =>
      'माला गणक अनुप्रयोग माला या जप की गिनती के एक सामान्य परिदृश्य को हल करने के लिए बनाया गया है जो हिंदू धर्म के लोगों द्वारा ध्यान के दौरान किया जाता है।\n\nहिंदू धर्म में जप माला का उपयोग ध्यान के दौरान मंत्रों के पाठ को निर्देशित करने और गिनने के लिए किया जाता है। इसमें आमतौर पर जीवन की चक्रीय प्रकृति का प्रतिनिधित्व करने के लिए एक चक्र में पिरोए गए 108 मोती होते हैं।';

  @override
  String get menu => 'सूची';

  @override
  String changeLanguageTo({required String language}) {
    return 'भाषा को $language में बदलें';
  }

  @override
  String get english => 'अंग्रेज़ी';

  @override
  String get hindi => 'हिन्दी';

  @override
  String get backupToExcel => 'एक्सेल में माला का बैकअप लें';

  @override
  String get restoreFromExcel => 'एक्सेल से माला पुनर्स्थापित करें';

  @override
  String get backupToGD => 'गूगल ड्राइव पर बैकअप लें';

  @override
  String get restoreFromGD => 'गूगल ड्राइव से पुनर्स्थापित करें';

  @override
  String get deleteBackupFromGD => 'गूगल ड्राइव से बैकअप हटाएं';

  @override
  String get signOutFromGD => 'गूगल ड्राइव से साइन आउट करें';

  @override
  String get newFamily => 'नया परिवार';

  @override
  String get vyasFamily => 'व्यास परिवार';

  @override
  String get kadvawatFamily => 'कड़वावत परिवार';

  @override
  String get dharmawatFamily => 'धर्मावत परिवार';

  @override
  String get excelSaveSuccessful => 'एक्सेल सफलतापूर्वक सहेजा गया।';

  @override
  String get gdRestoreSuccessful => 'गूगल ड्राइव पुनःस्थापना सफल रहा।';

  @override
  String get excelRestoreSuccessful => 'एक्सेल पुनर्स्थापना सफल रहा।';

  @override
  String get gdBackupSuccessful => 'गूगल ड्राइव बैकअप सफलतापूर्वक किया गया।';

  @override
  String get excelBackupSuccessful => 'एक्सेल बैकअप सफलतापूर्वक किया गया।';

  @override
  String get gdDataDeleteSuccessful =>
      'गूगल ड्राइव से ऐप डेटा सफलतापूर्वक हटा दिया गया।';

  @override
  String get changingLanguage => 'भाषा बदल रहे है।';

  @override
  String get backupInProgress => 'बैकअप कर रहे है।';

  @override
  String get restoringFromBackup => 'बैकअप से पुनर्स्थापित कर रहे है।';

  @override
  String get excelBackupInProgress => 'एक्सेल बैकअप प्रगति पर है।';

  @override
  String get restoringFromExcel => 'एक्सेल से पुनर्स्थापित कर रहे है।';

  @override
  String get deletingBackupFromGD => 'गूगल ड्राइव से बैकअप हटा रहे है।';

  @override
  String get signingOutFromGD => 'गूगल ड्राइव से साइन आउट कर रहे है।';

  @override
  String get malaNotAvailable => 'कोई माला उपलब्ध नहीं है।';

  @override
  String get familyNotAvailable => 'कोई परिवार उपलब्ध नहीं है।';

  @override
  String get backupNotAvailable => 'बैकअप उपलब्ध नहीं है।';

  @override
  String get saveError => 'सहेजना विफल रहा।';

  @override
  String get backupError => 'बैकअप विफल रहा।';

  @override
  String get restoreError => 'Restore विफल रहा।';

  @override
  String get deleteError => 'पुनर्स्थापन विफल रहा।';

  @override
  String deleteConfirmation({required String name}) {
    return 'क्या आप वाकई $name को हटाना चाहते हैं?';
  }

  @override
  String get alert => 'सूचना';

  @override
  String get delete => 'मिटाए';

  @override
  String get cancel => 'रद्द करे';

  @override
  String get renameToYourFamilyName => 'नाम बदलकर अपने पारिवार का नाम रखें।';

  @override
  String get added => 'जोड़ दिया गया है।';

  @override
  String get updated => 'अपडेट कर दिया गया है।';

  @override
  String get deleted => 'हटा दिया गया है।';

  @override
  String get alreadyExists => 'पहले से ही मौजूद है।';

  @override
  String get enterFamilyName => 'परिवार का नाम प्रविष्ट करे।';

  @override
  String get enterParentsName => 'अभिभावको का नाम प्रविष्ट करें।';

  @override
  String get enterChildAndSpouseName =>
      'बच्चे और उसके जीवनसाथी का नाम प्रविष्ट करें।';

  @override
  String get familyMemberDetails => 'परिवार के सदस्य का विवरण';

  @override
  String get memberName => 'सदस्य का नाम';

  @override
  String get spouseName => 'जीवनसाथी का नाम';

  @override
  String get image => 'चित्र';

  @override
  String get commonError =>
      'कुछ गलत हो गया है। कृपया बाद में दोबारा प्रयास करें।';
}
