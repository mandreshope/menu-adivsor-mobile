import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:menu_advisor/src/models.dart';
import 'package:menu_advisor/src/services/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthContext extends ChangeNotifier {
  User _currentUser;
  Api _api = Api.instance;
  Future initialized;

  set currentUser(User user) {
    _currentUser = user;
    notifyListeners();
    if (user != null)
      SharedPreferences.getInstance().then((sharedPrefs) {
        sharedPrefs.setString('currentUser', json.encode(user.toJson()));
      });
    else
      SharedPreferences.getInstance().then((sharedPrefs) {
        sharedPrefs.remove('currentUser');
      });
  }

  User get currentUser => _currentUser;

  AuthContext() {
    initialized = _loadUser();
  }

  Future _loadUser() async {
    final sharedPrefs = await SharedPreferences.getInstance();

    if (sharedPrefs.containsKey('currentUser') &&
        sharedPrefs.getString('currentUser') != null) {
      Map<String, dynamic> jsonMap =
          json.decode(sharedPrefs.getString('currentUser'));

      currentUser = User.fromJson(jsonMap);
    }

    return;
  }

  Future<bool> login(String email, String password) => _api
          .login(
        email,
        password,
      )
          .then<bool>((User user) {
        currentUser = user;
        notifyListeners();
        return true;
      }).catchError((error) {
        return Future.error(error['body']);
      });

  Future<bool> logout() async {
    currentUser = null;
    return await _api.logout();
  }

  Future<String> signup({
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
          .then<String>(
            (registrationToken) => registrationToken,
          );
}
