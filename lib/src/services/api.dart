import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:menu_advisor/src/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Api {
  final String _apiURL = 'https://menu-advisor.herokuapp.com/api';
  String _token;

  Api._privateConstructor() {
    _checkExistingTokenCache();
  }

  _checkExistingTokenCache() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('token')) _token = prefs.getString('token');
  }

  static Api _instance;

  static get instance => _instance ?? Api._privateConstructor();

  Future<User> login(String email, String password) {
    return http.post(
      '$_apiURL/login',
      body: {
        'email': email,
        'password': password,
      },
    ).then((response) {
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        _token = data['access_token'];
        User user = User.fromJson(data['user']);
        return user;
      }
      return Future.error({
        'status': response.statusCode,
        'body': json.decode(response.body),
      });
    });
  }

  Future<User> register({
    String email,
    String phoneNumber,
    String password,
  }) {
    return http.post(
      '$_apiURL/users/register',
      body: {
        'email': email,
        'password': password,
        'phoneNumber': phoneNumber,
      },
    ).then((response) {
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        User user = User.fromJson(data['newUser']);
        return user;
      }
      return Future.error({
        'status': response.statusCode,
        'body': json.decode(response.body),
      });
    });
  }

  Future<List<Restaurant>> getRestaurants({
    Map<String, dynamic> filters,
  }) {
    String query = '';
    if (filters != null) {
      List<String> keys = filters.keys.toList();
      if (keys.length > 0) {
        query = '?';
        for (int i = 0; i < keys.length; i++) {
          final key = keys[i];
          query += '$key=${filters[key]}';
          if (i < keys.length - 1) query += '&';
        }
      }
    }

    return http.get('$_apiURL/restaurants$query').then((response) {
      if (response.statusCode == 200) {
        List<Map<String, dynamic>> list = json.decode(response.body);
        return list.map((data) => Restaurant.fromJson(data)).toList();
      }

      return Future.error(json.decode(response.body));
    }).catchError((error) {
      return Future.error(error);
    });
  }

  Future<List<Food>> getFoods({
    Map<String, String> filters,
  }) {
    String query = '';
    if (filters != null) {
      List<String> keys = filters.keys.toList();
      if (keys.length > 0) {
        query = '?';
        for (int i = 0; i < keys.length; i++) {
          final key = keys[i];
          query += '$key=${filters[key]}';
          if (i < keys.length - 1) query += '&';
        }
      }
    }

    return http.get(
      '$_apiURL/foods$query',
      headers: {
        "authorization": "Bearer $_token",
      },
    ).then((response) {
      if (response.statusCode == 200) {
        List<Map<String, dynamic>> list = json.decode(response.body);
        return list.map((data) => Food.fromJson(data)).toList();
      }

      return Future.error(json.decode(response.body));
    }).catchError((error) {
      return Future.error(error);
    });
  }

  Future<bool> addToFavoriteFood(Food food) {
    return http.post('$_apiURL/users/favoriteFood/add', body: {
      "id": food.id,
    }, headers: {
      "authorization": "Bearer $_token",
    }).then((response) {
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    }).catchError((error) {
      return Future.error(error);
    });
  }

  Future removeFromFavoriteFood(Food food) {
    return http.post('$_apiURL/users/favoriteFood/delete', body: {
      "id": food.id,
    }, headers: {
      "authorization": "Beare $_token",
    }).then((response) {
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    }).catchError((error) {
      return Future.error(error);
    });
  }
}
