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
          jsonDecode(sharedPrefs.getString('currentUser'));

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
      _api.register(
        email: email,
        phoneNumber: phoneNumber,
        password: password,
      );

  addToFavoriteFoods(Food food) async {
    if (_currentUser.favoriteFoods
            .firstWhere((element) => element.id == food.id, orElse: null) !=
        null) return false;

    await _api.addToFavoriteFood(food);
    _currentUser.favoriteFoods.add(food);
    notifyListeners();
  }

  removeFromFavoriteFoods(Food food) async {
    await _api.removeFromFavoriteFoods(food);
    currentUser = await _api.getMe();
    notifyListeners();
  }

  addToFavoriteRestaurants(Restaurant restaurant) async {
    await _api.addToFavoriteRestaurants(restaurant);
    currentUser = await _api.getMe();
    notifyListeners();
  }

  removeFromFavoriteRestaurants(Restaurant restaurant) async {
    await _api.removeFromFavoriteRestaurants(restaurant);
    currentUser = await _api.getMe();
    notifyListeners();
  }

  resendConfirmationCode() => _api.resendConfirmationCode();

  Future<String> resetPassword(String email) => _api.resetPassword(email);

  Future validateAccount({
    String registrationToken,
    int code,
  }) =>
      _api.validateAccount(
        registrationToken: registrationToken,
        code: code,
      );

  Future<bool> confirmResetPassword({
    String token,
    int code,
    String password,
  }) =>
      _api.confirmResetPassword(
        token: token,
        code: code,
        password: password,
      );
}
