import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingContext extends ChangeNotifier {
  String _languageCode = 'system';
  Future<void> initialized;

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
    languageCode = 'system';
  }
}
