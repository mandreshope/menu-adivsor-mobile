import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:menu_advisor/src/models.dart';
import 'package:menu_advisor/src/services/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthContext extends ChangeNotifier {
  User _currentUser;
  Api _api = Api.instance;

  set currentUser(User user) {
    _currentUser = user;
    SharedPreferences.getInstance().then((sharedPrefs) {
      sharedPrefs.setString('currentUser', json.encode(user.toJson()));
    });
  }

  User get currentUser => _currentUser;

  AuthContext() {
    _loadUser();
  }

  _loadUser() async {
    final sharedPrefs = await SharedPreferences.getInstance();

    if (sharedPrefs.containsKey('currentUser') &&
        sharedPrefs.getString('currentUser') != null) {
      Map<String, dynamic> jsonMap =
          json.decode(sharedPrefs.getString('currentUser'));

      currentUser = User.fromJson(jsonMap);
    }
  }

  Future<bool> login(String email, String password) => _api
          .login(
        email,
        password,
      )
          .then((User user) {
        currentUser = user;
        notifyListeners();
        return true;
      }).catchError((error) {
        return Future.error(error['body']);
      });

  Future<bool> logout() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return await sharedPreferences.remove('currentUser') && await _api.logout();
  }

  Future<bool> signup({
    String email,
    String phoneNumber,
    String password,
  }) =>
      _api
          .register(
        email: email,
        phoneNumber: phoneNumber,
        password: password,
      )
          .then((User user) {
        currentUser = user;
        notifyListeners();
        return true;
      }).catchError((error) {
        if (error is Map<String, dynamic> && error.containsKey('body'))
          return Future.error(error['body']);

        return Future.error(error);
      });
}
