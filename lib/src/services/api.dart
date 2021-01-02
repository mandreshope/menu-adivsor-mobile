import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:menu_advisor/src/models.dart';
import 'package:menu_advisor/src/types.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Api {
  // final String _apiURL = 'https://menu-advisor.herokuapp.com';
  final String _apiURL = 'https://preprod-api.clicar.fr';
  String _accessToken;
  String _refreshToken;

  Future init(String accessToken, String refreshToken) async {
    accessToken = accessToken;
    refreshToken = refreshToken;

    await _refreshTokens();
  }

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
    if (registrationToken == null) return Future.error(Exception('No registration token provided'));

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
    if (prefs.containsKey('access_token') && prefs.containsKey('refresh_token')) {
      _accessToken = prefs.getString('access_token');
      _refreshToken = prefs.getString('refresh_token');
      await _refreshTokens();
    }
  }

  Future _refreshTokens() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    var newTokens = await _checkToken();
    if (newTokens != null && newTokens.length > 0) {
      _accessToken = newTokens[0];
      _refreshToken = newTokens[1];

      prefs.setString('access_token', _accessToken);
      prefs.setString('refresh_token', _refreshToken);
    }

    return;
  }

// asina time out
  Future<List<String>> _checkToken() {
    if (_accessToken == null || _refreshToken == null) return null;
    return http.get('$_apiURL/check-token?access_token=$_accessToken&refresh_token=$_refreshToken').then<List<String>>((response) {
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
        'phoneNumber': email,
        'password': password,
      },
    ).then<User>((response) {
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        accessToken = data['access_token'];
        refreshToken = data['refresh_token'];
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

    return await sharedPrefs.remove('access_token') && await sharedPrefs.remove('refresh_token');
  }

  Future<String> register({
    String email,
    String phoneNumber,
    String password,
    String firstName,
    String lastName
  }) {
    
    return http.post(
      '$_apiURL/users/register',
      body: jsonEncode({
        'email': email,
        'password': password,
        'phoneNumber': phoneNumber,
        'name':{
          'first':firstName,
          'last':lastName
        }
      }),
      headers:{
        'content-type': 'application/json'
      }
    ).then<String>((response) {
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        String registrationToken = data['token'];
        return registrationToken;
      }

      return Future.error(
        jsonDecode(response.body),
      );
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

    return http.get('$_apiURL/restaurants$query').then<List<Restaurant>>((response) {
      if (response.statusCode == 200) {
        List<dynamic> list = jsonDecode(response.body);
        return list.map((data) => Restaurant.fromJson(data)).toList();
      }

      return Future.error(
        jsonDecode(response.body),
      );
    });
  }

  Future<List<Food>> getFoods(
    String lang, {
    Map<String, dynamic> filters,
  }) {
    String query = '?lang=$lang';
    if (filters != null) {
      List<String> keys = filters.keys.toList();
      if (keys.length > 0) {
        for (int i = 0; i < keys.length; i++) {
          query += '&';
          final key = keys[i];
          query += '$key=${filters[key]}';
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
        return list.map((data) => Food.fromJson(data)).where((element) => element.status).toList();
      }

      return Future.error(
        jsonDecode(response.body),
      );
    });
  }

  Future<List<FoodCategory>> getFoodCategories(
    String lang,
  ) =>
      http.get('$_apiURL/foodCategories?lang=$lang').then<List<FoodCategory>>((response) {
        if (response.statusCode == 200) {
          List<dynamic> list = jsonDecode(response.body);
          return list.map((data) => FoodCategory.fromJson(data)).toList();
        }

        return Future.error(
          jsonDecode(response.body),
        );
      });

  Future<Food> getFood({
    String id,
    String lang,
  }) =>
      http.get(
        '$_apiURL/foods/$id?lang=$lang',
        headers: {
          "authorization": "Bearer $_accessToken",
        },
      ).then<Food>((response) {
        if (response.statusCode == 200) return Food.fromJson(jsonDecode(response.body));

        return Future.error(
          jsonDecode(response.body),
        );
      });

  Future<Restaurant> getRestaurant({
    String id,
    String lang,
  }) =>
      http.get(
        '$_apiURL/restaurants/$id?lang=$lang',
        headers: {
          "authorization": "Bearer $_accessToken",
          'content-type': 'application/json'
        },
      ).then<Restaurant>((response) {
        if (response.statusCode == 200) return Restaurant.fromJson(jsonDecode(response.body));

        return Future.error(
          jsonDecode(response.body),
        );
      });

  Future<bool> addToFavoriteFood(Food food) async {
    await _refreshTokens();

    return http.post('$_apiURL/users/favoriteFoods', body: {
      "id": food.id,
    }, headers: {
      "authorization": "Bearer $_accessToken",
    }).then((response) {
      if (response.statusCode == 200) return true;

      return false;
    });
  }

  Future removeFromFavoriteFoods(Food food) async {
    await _refreshTokens();

    return http.delete('$_apiURL/users/favoriteFoods/${food.id}', headers: {
      "authorization": "Bearer $_accessToken",
    }).then((response) {
      if (response.statusCode == 200) return true;

      return false;
    });
  }

  Future<bool> addToFavoriteRestaurants(Restaurant restaurant) async {
    await _refreshTokens();

    return http.post('$_apiURL/users/favoriteRestaurants', body: {
      "id": restaurant.id,
    }, headers: {
      "authorization": "Bearer $_accessToken",
    }).then((response) {
      if (response.statusCode == 200) return true;

      return false;
    });
  }

  Future removeFromFavoriteRestaurants(Restaurant restaurant) async {
    await _refreshTokens();

    return http.delete('$_apiURL/users/favoriteRestaurants/${restaurant.id}', headers: {
      "authorization": "Bearer $_accessToken",
    }).then((response) {
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    });
  }

  Future<List<SearchResult>> search(
    String query,
    String lang, {
    String type,
    Map<String, dynamic> filters,
    int range = 20,
    Map location,
  }) {
    String searchQuery;
    
    if (location == null){
      searchQuery = '?lang=$lang&q=$query&range=$range';
    }else{
     searchQuery = '?lang=$lang&q=$query&range=$range&location=${jsonEncode(location)}';
    }
     
    if (type is String) searchQuery += '&type=$type';
    if (filters != null && filters.length > 0) {
      var filterQuery = 'filter=${jsonEncode(filters)}';
      searchQuery += '&$filterQuery';
    }
    print(searchQuery);

    return http.get('$_apiURL/search$searchQuery').then<List<SearchResult>>((response) {
      if (response.statusCode == 200) {
        List<dynamic> results = jsonDecode(response.body);
        return results.map((e) => SearchResult.fromJson(e)).where((element) => element.content['status'] ?? true).toList();
      }

      return Future.error(
        jsonDecode(response.body),
      );
    });
  }

  Future<String> getRestaurantName({String id}) => http.get('$_apiURL/restaurants/$id/name').then<String>((response) {
        if (response.statusCode == 200) {
          return response.body;
        }

        return Future.error(
          jsonDecode(response.body),
        );
      });

  Future<String> resetPassword(String email) => http.post('$_apiURL/users/reset-password', body: {
        'email': email,
      }).then<String>((response) {
        if (response.statusCode == 200) {
          Map<String, dynamic> data = jsonDecode(response.body);
          return data['token'];
        }

        return Future.error(
          jsonDecode(response.body),
        );
      });

  Future<bool> confirmResetPassword({
    String token,
    int code,
    String password,
  }) =>
      http.post('$_apiURL/users/confirm-reset-password', body: {
        'token': token,
        'code': code.toString(),
        'password': password,
      }).then<bool>((response) {
        if (response.statusCode == 200) return true;

        return false;
      });

  Future<User> getMe() async {
    await _refreshTokens();

    return http.get('$_apiURL/users/me', headers: {
      'authorization': 'Bearer $_accessToken',
    }).then<User>(
      (response) {
        if (response.statusCode == 200) return User.fromJson(jsonDecode(response.body));

        return Future.error(
          jsonDecode(response.body),
        );
      },
    );
  }

  Future addPaymentCard(PaymentCard paymentCard) async {
    await _refreshTokens();

    return http.post('$_apiURL/users/paymentCards', body: paymentCard.toJson().map<String, String>((key, value) => MapEntry(key, value.toString())), headers: {
      'authorization': 'Bearer $_accessToken',
    }).then(
      (response) {
        if (response.statusCode != 200)
          return Future.error(
            jsonDecode(response.body),
          );
      },
    );
  }

  Future<List<Menu>> getMenus(String lang, String id) => http.get('$_apiURL/restaurants/$id/menus?lang=$lang').then<List<Menu>>(
  // Future<List<Menu>> getMenus(String lang, String id) => http.get('$_apiURL/restaurants/$id/menus').then<List<Menu>>(
        (response) {
          if (response.statusCode == 200) {
            List<dynamic> datas = jsonDecode(response.body);
            return datas.map<Menu>((e) => Menu.fromJson(e,fromCommand: true)).toList();
          }

          return Future.error(
            jsonDecode(response.body),
          );
        },
      );

  Future updatePassword(String oldPassword, String newPassword) async {
    await _refreshTokens();

    return http.post('$_apiURL/users/update-password', body: {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
    }, headers: {
      'authorization': 'Bearer $_accessToken',
    }).then(
      (response) {
        if (response.statusCode != 200)
          return Future.error(
            jsonDecode(response.body),
          );
      },
    );
  }

  Future removePaymentCard(PaymentCard creditCard) async {
    await _refreshTokens();

    return http.delete('$_apiURL/users/paymentCards/${creditCard.id}', headers: {
      'authorization': 'Bearer $_accessToken',
    }).then(
      (response) {
        if (response.statusCode != 200)
          return Future.error(
            jsonDecode(response.body),
          );
      },
    );
  }

  Future updateUserProfile(String id, Map<String, dynamic> data) async {
    await _refreshTokens();

    return http
        .put(
      '$_apiURL/users/$id',
      headers: {
        'authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    )
        .then(
      (response) {
        if (response.statusCode != 200)
          return Future.error(
            jsonDecode(response.body),
          );
      },
    );
  }

  Future<List<Command>> getCommandOfUser(
    User user, {
    int limit,
    int offset = 0,
  }) async {
    await _refreshTokens();

    return http.get('$_apiURL/commands?filter={"relatedUser": "${user.id}"}&offset=$offset${limit != null ? '&limit=$limit' : ''}', headers: {
      'authorization': 'Bearer $_accessToken',
      'Content-Type': 'application/json',
    }).then<List<Command>>((response) {
      if (response.statusCode == 200) {
        List datas = jsonDecode(response.body);
        return datas.map<Command>((data) => Command.fromJson(data)).toList();
      }

      // return Future.error(jsonDecode(response.body));
      return List();
    });
  }

  Future<Map> sendCommand({
    String relatedUser,
    String commandType,
    int totalPrice,
    String restaurant,
    var items,
    int shippingTime,
    String shippingAddress,
    bool shipAsSoonAsPossible,
    Map customer,
    var menu,
    String comment
  }) async {
    await _refreshTokens();
    var post = jsonEncode({
        'relatedUser': relatedUser,
        'commandType': commandType,
        'totalPrice': totalPrice.toString(),
        'restaurant': restaurant,
        'items': items,
        'shippingTime': shippingTime,
        'shippingAddress': shippingAddress,
        'shipAsSoonAsPossible': shipAsSoonAsPossible,
        'customer': customer,
        'menus':menu,
        'comment':comment
      });
    print(post);
    return http
        .post(
      '$_apiURL/commands',
      headers: {
        'authorization': 'Bearer $_accessToken',
        'Content-type': 'application/json',
      },
      body: jsonEncode({
        'relatedUser': relatedUser,
        'commandType': commandType,
        'totalPrice': totalPrice.toString(),
        'restaurant': restaurant,
        'items': items,
        'shippingTime': shippingTime,
        'shippingAddress': shippingAddress,
        'shipAsSoonAsPossible': shipAsSoonAsPossible,
        'customer': customer,
        'menus':menu,
        'comment':comment
      }),
    )
        .then<Map>((response) {
      if (response.statusCode != 200)
        return Future.error(
          jsonDecode(response.body),
        );

      return jsonDecode(response.body);
    });
  }

  Future setCommandToPayedStatus({
    String id,
    String paymentIntentId,
  }) async {
    await _refreshTokens();

    return http
        .put(
      '$_apiURL/commands/$id',
      headers: {
        'authorization': 'Bearer $_accessToken',
        'Content-type': 'application/json',
      },
      body: jsonEncode(
        {
          'payed': {
            'status': true,
            'paymentIntentId': paymentIntentId,
          }
        },
      ),
    )
        .then((response) {
      if (response.statusCode != 200) return Future.error(jsonDecode(response.body));
    });
  }


Future<FoodAttribute> getFoodAttribute({
    String id
  }) async {
    await _refreshTokens();

    return http.get('$_apiURL/foodAttributes/$id', headers: {
      'authorization': 'Bearer $_accessToken',
      'Content-Type': 'application/json',
    }).then<FoodAttribute>((response) {
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return FoodAttribute.fromJson(data);
      }

      return Future.error(jsonDecode(response.body));
    });
  }

Future<List<FoodAttribute>> getFoodAttributes() async {
    await _refreshTokens();

    return http.get('$_apiURL/foodAttributes', headers: {
      'authorization': 'Bearer $_accessToken',
      'Content-Type': 'application/json',
    }).then<List<FoodAttribute>>((response) {
      if (response.statusCode == 200) {
        List datas = jsonDecode(response.body);
        return datas.map<FoodAttribute>((data) => FoodAttribute.fromJson(data)).toList();
      }

      return Future.error(jsonDecode(response.body));
    });
  }

  Future<dynamic> getCityFromCoordinates(double latitude, double longitude) async {

    final String geoUrl = "https://nominatim.openstreetmap.org/reverse?format=geojson&lat=$latitude&lon=$longitude";
    return http.get(geoUrl).then((value) {
      Placemark data = Placemark.fromJson(json.decode(value.body));
      // var js = json.decode(value.body);
      String city =  data.features.first.properties.address.city;
      return city;
    }).catchError((onError){
      return Future.error(onError.toString());
    });

  }

 Future<bool> sendMessage(Message message) async {
    await _refreshTokens();
    return http.post(
      '$_apiURL/messages',
      body: json.encode(message.toJson()),
      headers:{
        'content-type': 'application/json'
      }
    ).then((response) {
       if (response.statusCode == 200) return true;
      print(jsonDecode(response.body));
      return false;
    });
  }


  Future<List<Blog>> getBlog() async {
    // await _refreshTokens();

    return http.get('$_apiURL/posts', headers: {
      'Content-Type': 'application/json',
    }).then<List<Blog>>((response) {
      if (response.statusCode == 200) {
        List datas = jsonDecode(response.body);
        return datas.map<Blog>((data) => Blog.fromJson(data)).toList();
      }
      return Future.error(jsonDecode(response.body));
    });
  }

  
Future<Map<String,dynamic>> ConfirmSms(String idCommande, String code) async {
   await _refreshTokens();
    return http.post(
      '$_apiURL/commands/$idCommande/confirm',
      body: json.encode({
        'code':code
      }),
      headers:{
        'content-type': 'application/json',
        "authorization": "Bearer $_accessToken",
      }
    ).then((response) {
       if (response.statusCode == 200) return jsonDecode(response.body);
      print(jsonDecode(response.body));
      return jsonDecode(response.body);
    });
}

}

