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
}
