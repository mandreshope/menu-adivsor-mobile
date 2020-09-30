import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingContext extends ChangeNotifier {
  String languageCode;
  Future initialized;

  SettingContext() {
    initialized = _loadCurrentUserSettings();
  }

  Future _loadCurrentUserSettings() async {
    SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    if (sharedPrefs.containsKey('languageCode')) {
      languageCode = sharedPrefs.getString('languageCode');
      notifyListeners();
    } else {
      sharedPrefs.setString(
        'languageCode',
        languageCode,
      );
    }
    return;
  }
}
