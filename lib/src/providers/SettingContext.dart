import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingContext extends ChangeNotifier {
  String _languageCode;
  Future<void> initialized;

  String get languageCode => _languageCode;

  set languageCode(String value) {
    _languageCode = value;
    notifyListeners();
  }

  SettingContext() {
    initialized = _loadCurrentUserSettings();
  }

  Future<void> _loadCurrentUserSettings() async {
    SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    if (sharedPrefs.containsKey('languageCode')) {
      languageCode = sharedPrefs.getString('languageCode');
    } else {
      await sharedPrefs.setString(
        'languageCode',
        languageCode,
      );
    }
    return;
  }
}
