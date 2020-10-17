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
    if (_currentUser == null) {
      SharedPreferences.getInstance().then((prefs) {
        prefs.remove('access_token');
        prefs.remove('refresh_token');
      });
    }
  }

  User get currentUser => _currentUser;

  AuthContext() {
    initialized = _loadUser();
  }

  Future _loadUser() async {
    final sharedPrefs = await SharedPreferences.getInstance();

    if (sharedPrefs.containsKey('access_token') && sharedPrefs.containsKey('refresh_token')) {
      String accessToken = sharedPrefs.getString('access_token');
      String refreshToken = sharedPrefs.getString('refresh_token');
      _api.init(accessToken, refreshToken);
      currentUser = await _api.getMe();
    }
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

  Future addToFavoriteFoods(Food food) async {
    await _api.addToFavoriteFood(food);
    _currentUser.favoriteFoods.add(food.id);
    notifyListeners();
    return;
  }

  Future removeFromFavoriteFoods(Food food) async {
    await _api.removeFromFavoriteFoods(food);
    currentUser.favoriteFoods.removeWhere((e) => e == food.id);
    notifyListeners();
    return;
  }

  Future addToFavoriteRestaurants(Restaurant restaurant) async {
    await _api.addToFavoriteRestaurants(restaurant);
    currentUser.favoriteRestaurants.add(restaurant.id);
    notifyListeners();
    return;
  }

  Future removeFromFavoriteRestaurants(Restaurant restaurant) async {
    await _api.removeFromFavoriteRestaurants(restaurant);
    currentUser.favoriteRestaurants.removeWhere((e) => e == restaurant.id);
    notifyListeners();
    return;
  }

  resendConfirmationCode() => _api.resendConfirmationCode();

  Future<String> resetPassword(String email) => _api.resetPassword(email);

  Future addPaymentCard(PaymentCard paymentCard) async {
    await _api.addPaymentCard(paymentCard);
    currentUser.paymentCards.add(paymentCard);
    notifyListeners();
    return;
  }

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

  Future updatePassword(String oldPassword, String newPassword) => _api.updatePassword(oldPassword, newPassword);

  Future removePaymentCard(PaymentCard creditCard) async {
    await _api.removePaymentCard(creditCard);
    currentUser = await _api.getMe();
  }

  Future updateUserProfile(Map<String, dynamic> data) async {
    await _api.updateUserProfile(
      currentUser.id,
      data,
    );
    currentUser = await _api.getMe();
  }
}
