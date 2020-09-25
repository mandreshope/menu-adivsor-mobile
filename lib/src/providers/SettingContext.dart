import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingContext extends ChangeNotifier {
  String languageCode;

  ChangeNotifier(BuildContext context) {
    _loadCurrentUserSettings(context);
  }

  _loadCurrentUserSettings(BuildContext context) async {
    SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    if (sharedPrefs.containsKey('languageCode')) {

    } else {
      sharedPrefs.setString('languageCode', Localizations.localeOf(context).languageCode);

    }
  }
}