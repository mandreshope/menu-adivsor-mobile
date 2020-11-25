import 'dart:convert';

import 'package:firebase_mlkit_language/firebase_mlkit_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:menu_advisor/src/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingContext extends ChangeNotifier {
  String _languageCode = 'fr';
  Future<void> initialized;
  List<String> _languageCodes = [
    SupportedLanguages.English,
    SupportedLanguages.Japanese,
    SupportedLanguages.Chinese,
    SupportedLanguages.French,
    SupportedLanguages.Italian,
    SupportedLanguages.Spanish,
    SupportedLanguages.Russian,
    SupportedLanguages.Korean,
    SupportedLanguages.Dutch,
    SupportedLanguages.German,
  ];

  List<String> _languages = [
    "ANGLAIS",
    "JAPONAIS",
    "CHINOIS",
    "ARABE",
    "FRANCAIS",
    "ITALIEN",
    "ESPAGNOL",
    "RUSSE",
    "CORÉEN",
    "NÉÉRLENDAIS",
    "ALLEMAND"
  ];

  get languages => _languages;
  get languageCodes => _languageCodes;

  String get languageCode => _languageCode;
  /*_languageCode == 'fr'
      ? WidgetsBinding.instance.window.locale.languageCode
      : _languageCode;*/

  bool get isSystemSetting => _languageCode == 'system';

  set languageCode(String value) {
    _languageCode = value;
    notifyListeners();
    SharedPreferences.getInstance().then((sharedPrefs) {
      sharedPrefs.setString('languageCode', value);
    });
  }

  SettingContext() {
    initialized = _loadCurrentUserSettings();
  }

  Future<void> _loadCurrentUserSettings() async {
    SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    if (sharedPrefs.containsKey('languageCode')) {
      languageCode = sharedPrefs.getString('languageCode');
      notifyListeners();
    } else {
      await sharedPrefs.setString(
        'languageCode',
        languageCode,
      );
    }
    return;
  }

  resetLanguage() {
    languageCode = 'fr';
  }

  Future<void> downloadLanguage() async  {
      print("download loading...");
      
      await Future.forEach(_languageCodes, (item) => FirebaseLanguage.instance.modelManager().downloadModel(item));

     print("download finish...");
  }


}
