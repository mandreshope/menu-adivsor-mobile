import 'dart:convert';

import 'package:firebase_mlkit_language/firebase_mlkit_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:menu_advisor/src/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingContext extends ChangeNotifier {
  String _languageCode = 'fr';
  String _languageCodeRstaurant = 'fr';
  Future<void> initialized;
  int range = 1;

  bool _isRestaurantPage = false;
  bool isDownloadingLang = true;
  
  set isRestaurantPage(bool value) {
     _isRestaurantPage = value;
      notifyListeners();
  }

  get isRestaurantPage => _isRestaurantPage;

  List<String> _supportedLanguages = [
    SupportedLanguages.French,
    SupportedLanguages.English,
    SupportedLanguages.Japanese,
    SupportedLanguages.Chinese,
    SupportedLanguages.Italian,
    SupportedLanguages.Spanish,
    SupportedLanguages.Russian,
    SupportedLanguages.Korean,
    SupportedLanguages.Dutch,
    SupportedLanguages.German,
  ];

  List<String> _languages = [
    "Français",
    "Anglais",
    "Japonais",
    "Chinois",
    "Italien",
    "Espaniol",
    "Russe",
    "Coréen",
    "Néérlendais",
    "Allemand"
  ];

  get languages => _languages;
  get supportedLanguages => _supportedLanguages;

  String get languageCodeTranslate => _languageCode;
  String get languageCodeRestaurantTranslate => _languageCodeRstaurant;
  
  String get languageCodeFlag {
    String code = isRestaurantPage ? _languageCodeRstaurant : _languageCode;
    switch(code){
      case "en":
        return 'us';
        case 'ja':
          return 'jp';
      case 'zh':
        return 'cn';
        case 'ko':
          return 'kr';
    }
    return code;
  }
  
  String get languageCode => _languageCode ?? 'fr';
  /*_languageCode == 'fr'
      ? WidgetsBinding.instance.window.locale.languageCode
      : _languageCode;*/

  bool get isSystemSetting => _languageCode == 'fr';

  set languageCode(String value) {
    _languageCode = value;
    Intl.defaultLocale = value;
    SharedPreferences.getInstance().then((sharedPrefs) {
      sharedPrefs.setString('languageCode', value);
    });
    notifyListeners();
  }

  set languageCodeRestaurant(String value) {
    _languageCodeRstaurant = value;
    notifyListeners();
    SharedPreferences.getInstance().then((sharedPrefs) {
      sharedPrefs.setString('languageCodeRestaurant', value);
    });
  }

  SettingContext() {
    initialized = _loadCurrentUserSettings();
  }

  Future<void> _loadCurrentUserSettings() async {
    SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    if (sharedPrefs.containsKey('languageCode') || sharedPrefs.containsKey('languageCodeRestaurant') ) {
      languageCode = sharedPrefs.getString('languageCode');
      languageCodeRestaurant = sharedPrefs.getString('languageCodeRestaurant');
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
    languageCodeRestaurant = 'fr';
  }

  Future<void> downloadLanguage() async  {
      print("download loading...");
      isDownloadingLang = true;
      notifyListeners();
      
      await Future.forEach(
          _supportedLanguages,
              (item) =>
                  FirebaseLanguage.instance.modelManager().downloadModel(item)
      );

      isDownloadingLang = false;
      notifyListeners();

     print("download finish...");

  }


}
