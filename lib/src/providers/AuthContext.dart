import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:menu_advisor/src/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthContext extends ChangeNotifier {
  User currentUser;

  AuthContext() {
    _loadUser();
  }

  _loadUser() async {
    final sharedPrefs = await SharedPreferences.getInstance();
    if (sharedPrefs.containsKey('currentUser') && sharedPrefs.getString('currentUser') != null) {
      Map<String, String> jsonMap = json.decode(sharedPrefs.getString('currentUser'));
      currentUser = User.fromJson(jsonMap);
    }
  }
}