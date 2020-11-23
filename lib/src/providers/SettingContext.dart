import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:menu_advisor/src/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingContext extends ChangeNotifier {
  String _languageCode = 'system';
  Future<void> initialized;
  List<Language> langs = List();


  String get languageCode => _languageCode == 'system'
      ? WidgetsBinding.instance.window.locale.languageCode
      : _languageCode;

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
    _loadLangFromAsset();
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

  Future<void> _loadLangFromAsset() async {
    var data = await rootBundle.loadString('lang/code.json');
    var jsonResult = json.decode(data);
    var result = (jsonResult as List).map<Language>((json) => Language.fromJson(json)).toList();
    this.langs.addAll(result);
    print(langs);
  }

  resetLanguage() {
    languageCode = 'system';
  }
}
