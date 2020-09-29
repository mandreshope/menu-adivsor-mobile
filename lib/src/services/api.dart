import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:menu_advisor/src/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Api {
  final String _apiURL = 'https://menu-advisor.herokuapp.com/api';
  String _accessToken;
  String _refreshToken;

  set accessToken(String accessToken) {
    _accessToken = accessToken;
    SharedPreferences.getInstance().then((sharedPrefs) {
      sharedPrefs.setString('access_token', accessToken);
    });
  }

  set refreshToken(String refreshToken) {
    _refreshToken = refreshToken;
    SharedPreferences.getInstance().then((sharedPrefs) {
      sharedPrefs.setString('refresh_token', refreshToken);
    });
  }

  String get accessToken => _accessToken;

  Api._privateConstructor() {
    _checkExistingTokenCache();
  }

  _checkExistingTokenCache() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('access_token') &&
        prefs.containsKey('refresh_token')) {
      _accessToken = prefs.getString('access_token');
      _refreshToken = prefs.getString('refresh_token');
    }
    // var newTokens = await _checkToken();
    // if (newTokens != null)
  }

  // Future _checkToken() {
  //   return http.get('$_apiURL/check-token?access_token=$_accessToken&refresh_token=$_refreshToken').then((response) {
  //     if (response.statusCode == 200) {}
  //   });
  // }

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
        accessToken = data['access_token'];
        User user = User.fromJson(data['user']);
        return user;
      }
      return Future.error({
        'status': response.statusCode,
        'body': json.decode(response.body),
      });
    });
  }

  Future<bool> logout() async {
    SharedPreferences sharedPrefs = await SharedPreferences.getInstance();

    return await sharedPrefs.remove('access_token') &&
        await sharedPrefs.remove('refresh_token');
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

    var result = http
        .get('$_apiURL/restaurants$query')
        .then<List<Restaurant>>((response) {
      if (response.statusCode == 200) {
        List<dynamic> list = json.decode(response.body);
        return list.map((data) => Restaurant.fromJson(data)).toList();
      }

      return Future.error(json.decode(response.body));
    }).catchError((error) {
      return Future.error(error);
    });
    return result;
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
        "authorization": "Bearer $_accessToken",
      },
    ).then<List<Food>>((response) {
      if (response.statusCode == 200) {
        List<dynamic> list = json.decode(response.body);
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
      "authorization": "Bearer $_accessToken",
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
      "authorization": "Beare $_accessToken",
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
