import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:menu_advisor/src/models.dart';

class Api {
  final String _apiURL = 'https://menu-advisor.herokuapp.com/api';
  String _token;

  Api._privateConstructor();

  static Api _instance;

  static get instance => _instance ?? Api._privateConstructor();

  Future<User> login(String email, String password) {
    http.post(
      '$_apiURL/login',
      body: {
        'email': email,
        'password': password,
      }
    ).then((value) {
      if (value.statusCode == 200) {
        Map<String, String> data = json.decode(value.body);
        _token = data['access_token'];
      }
    });
  }

  Future<User> register(User user) {

  }
}
