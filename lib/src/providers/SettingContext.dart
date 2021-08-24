import 'package:firebase_mlkit_language/firebase_mlkit_language.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:menu_advisor/src/constants/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingContext extends ChangeNotifier {
  String _languageCode = 'fr';
  String _languageCodeRstaurant = 'fr';
  Future<void> initialized;
  int range = 10;
  int loadingIndex = 1;

  Position position;
  double distanceWithRestaurant = 0.0;

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
    SupportedLanguages.Portuguese,
    SupportedLanguages.Indonesian,
    SupportedLanguages.Arabic,
  ];

  List<String> _defaultSupportedLanguages = [
    SupportedLanguages.French,
    SupportedLanguages.English,
  ];

  List<String> _languages = ["Français", "Anglais", "Japonais", "Chinois", "Italien", "Espaniol", "Russe", "Coréen", "Néérlendais", "Allemand", "Portugais", "Inde", "Arabe"];

  get languages => _languages;
  get supportedLanguages => _supportedLanguages;

  String get languageCodeTranslate => _languageCode;
  String get languageCodeRestaurantTranslate => _languageCodeRstaurant;

  String get languageCodeFlag {
    String code = isRestaurantPage ? _languageCodeRstaurant : _languageCode;
    switch (code) {
      case "en":
        return 'us';
      case 'ja':
        return 'jp';
      case 'zh-CN':
      case 'zh':
        return 'cn';
      case 'ko':
        return 'kr';
      case 'ar':
        return "ae";
      case 'nl':
        return 'de';
    }
    return code;
  }

  String get languageCode => _languageCode ?? 'fr';
  /*_languageCode == 'fr'
      ? WidgetsBinding.instance.window.locale.languageCode
      : _languageCode;*/

  bool get isSystemSetting => _languageCode == 'fr';

  Future setlanguageCode(String value) async {
    print("$logTrace $value");
    var result = await FirebaseLanguage.instance.modelManager().downloadModel(value);
    _languageCode = value;
    Intl.defaultLocale = value;
    final sharedPrefs = await SharedPreferences.getInstance();
    sharedPrefs.setString('languageCode', value);
    notifyListeners();
    await Future.delayed(Duration(seconds: 5));
    return result;
  }

  Future setlanguageCodeRestaurant(String value) async {
    String lang = value;
    if (value == 'zh-CN') {
      lang = 'zh';
    } else if (value == 'nl') {
      lang = 'de';
    }
    var result = await FirebaseLanguage.instance.modelManager().downloadModel(lang);
    _languageCodeRstaurant = lang;
    SharedPreferences.getInstance().then((sharedPrefs) {
      sharedPrefs.setString('languageCodeRestaurant', lang);
    });
    notifyListeners();
    return result;
  }

  SettingContext() {
    initialized = _loadCurrentUserSettings();
    _listenLocation();
  }

  Future<void> _loadCurrentUserSettings() async {
    SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    if (sharedPrefs.containsKey('languageCode') || sharedPrefs.containsKey('languageCodeRestaurant')) {
      setlanguageCode(sharedPrefs.getString('languageCode'));
      setlanguageCodeRestaurant(sharedPrefs.getString('languageCodeRestaurant'));
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
    setlanguageCode('fr');
    setlanguageCodeRestaurant('fr');
  }

  Future<void> downloadLanguage() async {
    print("download loading...");
    isDownloadingLang = true;
    notifyListeners();
    await Future.forEach(_defaultSupportedLanguages, (item) {
      return FirebaseLanguage.instance.modelManager().downloadModel(item);
    });

    isDownloadingLang = false;
    notifyListeners();

    print("download finish...");
  }

  void _listenLocation() async {
    Geolocator.getPositionStream().listen((Position position) {
      // print('Current position stream: ${position.latitude},${position.longitude}');
      this.position = position;
    });
  }

  double distanceBetween(double lat, double long) {
    distanceWithRestaurant = Geolocator.distanceBetween(position.latitude, position.longitude, lat, long);
    return distanceWithRestaurant;
  }

  String distanceBetweenString(double lat, double long) {
    distanceWithRestaurant = Geolocator.distanceBetween(position.latitude, position.longitude, lat, long);
    if (distanceWithRestaurant >= 1000) {
      double km = distanceWithRestaurant / 1000;
      return km.toStringAsFixed(2) + " kilomètres";
    }
    return distanceWithRestaurant.toStringAsFixed(2) + " mètres";
  }
}
