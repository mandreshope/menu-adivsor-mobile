import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:menu_advisor/src/models.dart';
import 'package:menu_advisor/src/types.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Api {
  final String _apiURL = 'https://menu-advisor.herokuapp.com';
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

  Future resendConfirmationCode({String registrationToken}) {
    if (registrationToken == null)
      return Future.error(Exception('No registration token provided'));

    return http.post(
      '$_apiURL/users/resend-confirmation-code',
      body: {
        'token': registrationToken,
      },
    );
  }

  Future validateAccount({String registrationToken, int code}) {
    if (registrationToken == null || code == null)
      return Future.error(
        Exception('Registration token or confirmation code not provided'),
      );

    return http.post(
      '$_apiURL/users/confirm-account',
      body: {
        'token': registrationToken,
        'code': code.toString(),
      },
    ).then((response) async {
      if (response.statusCode == 200) return;

      return Future.error(jsonDecode(response.body));
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
      await _refreshTokens();
    }
  }

  Future _refreshTokens() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    var newTokens = await _checkToken();
    if (newTokens.length > 0) {
      _accessToken = newTokens[0];
      _refreshToken = newTokens[1];

      prefs.setString('access_token', _accessToken);
      prefs.setString('refresh_token', _refreshToken);
    }

    return;
  }

  Future<List<String>> _checkToken() {
    return http
        .get(
            '$_apiURL/check-token?access_token=$_accessToken&refresh_token=$_refreshToken')
        .then<List<String>>((response) {
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);

        if (result is Map<String, dynamic> && result.containsKey('validity')) {
          if (result['validity'] == 'valid')
            return [];
          else
            return [result['access_token'], result['refresh_token']];
        }
      }
      return [];
    });
  }

  static Api _instance;

  static Api get instance => _instance ?? Api._privateConstructor();

  Future<User> login(String email, String password) {
    return http.post(
      '$_apiURL/login',
      body: {
        'email': email,
        'password': password,
      },
    ).then<User>((response) {
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        accessToken = data['access_token'];
        User user = User.fromJson(data['user']);
        return user;
      }
      return Future.error({
        'status': response.statusCode,
        'body': jsonDecode(response.body),
      });
    });
  }

  Future<bool> logout() async {
    SharedPreferences sharedPrefs = await SharedPreferences.getInstance();

    return await sharedPrefs.remove('access_token') &&
        await sharedPrefs.remove('refresh_token');
  }

  Future<String> register({
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
    ).then<String>((response) {
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        String registrationToken = data['token'];
        return registrationToken;
      }

      return Future.error(jsonDecode(response.body));
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

    return http
        .get('$_apiURL/restaurants$query')
        .then<List<Restaurant>>((response) {
      if (response.statusCode == 200) {
        List<dynamic> list = jsonDecode(response.body);
        return list.map((data) => Restaurant.fromJson(data)).toList();
      }

      return Future.error(jsonDecode(response.body));
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
        "authorization": "Bearer $_accessToken",
      },
    ).then<List<Food>>((response) {
      if (response.statusCode == 200) {
        List<dynamic> list = jsonDecode(response.body);
        return list.map((data) => Food.fromJson(data)).toList();
      }

      return Future.error(jsonDecode(response.body));
    });
  }

  Future<List<FoodCategory>> getFoodCategories() =>
      http.get('$_apiURL/foodCategories').then<List<FoodCategory>>((response) {
        if (response.statusCode == 200) {
          List<dynamic> list = jsonDecode(response.body);
          return list.map((data) => FoodCategory.fromJson(data)).toList();
        }

        return Future.error(jsonDecode(response.body));
      });

  Future<Food> getFood({
    String id,
  }) =>
      http.get(
        '$_apiURL/foods/$id',
        headers: {
          "authorization": "Bearer $_accessToken",
        },
      ).then<Food>((response) {
        if (response.statusCode == 200)
          return Food.fromJson(jsonDecode(response.body));

        return Future.error(jsonDecode(response.body));
      });

  Future<Restaurant> getRestaurant({
    String id,
  }) =>
      http.get(
        '$_apiURL/restaurants/$id',
        headers: {
          "authorization": "Bearer $_accessToken",
        },
      ).then<Restaurant>((response) {
        if (response.statusCode == 200)
          return Restaurant.fromJson(jsonDecode(response.body));

        return Future.error(jsonDecode(response.body));
      });

  Future<bool> addToFavoriteFood(Food food) async {
    await _refreshTokens();

    return http.post('$_apiURL/users/favoriteFoods', body: {
      "id": food.id,
    }, headers: {
      "authorization": "Bearer $_accessToken",
    }).then((response) {
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    });
  }

  Future removeFromFavoriteFood(Food food) async {
    await _refreshTokens();

    return http.delete('$_apiURL/users/favoriteFoods/${food.id}', headers: {
      "authorization": "Beare $_accessToken",
    }).then((response) {
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    });
  }

  Future<List<SearchResult>> search(
    String query, {
    String type,
    Map<String, dynamic> filters,
  }) {
    String searchQuery = '?q=$query';
    if (type is String) searchQuery += '&type=$type';
    if (filters != null && filters.length > 0) {
      var filterQuery = 'filter={';
      filters.forEach((key, value) {
        filterQuery += '$key: $value,';
      });
      filterQuery += '}';
      searchQuery += '&$filterQuery';
    }

    return http
        .get('$_apiURL/search$searchQuery')
        .then<List<SearchResult>>((response) {
      if (response.statusCode == 200) {
        List<dynamic> results = jsonDecode(response.body);
        return results.map((e) => SearchResult.fromJson(e)).toList();
      }

      return Future.error(jsonDecode(response.body));
    });
  }

  Future removeFromFavoriteRestaurants(Restaurant restaurant) async {
    await _refreshTokens();

    return http.post('$_apiURL/users/favoriteRestaurant');
  }
}
