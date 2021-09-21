import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:menu_advisor/src/constants/constant.dart';
import 'package:menu_advisor/src/models/models.dart';
import 'package:menu_advisor/src/types/types.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Api {
  // final String _apiURL = 'https://menu-advisor.herokuapp.com';
  static final String _apiURL = 'https://api-advisor.voirlemenu.fr';
  static String get apiURL => _apiURL;
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

    final Uri url = Uri.parse('$_apiURL/users/resend-confirmation-code');
    print("$logTrace $url");

    return http.post(
      url,
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

    final Uri url = Uri.parse('$_apiURL/users/confirm-account');
    print("$logTrace $url");

    return http.post(
      url,
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
    return http.get(Uri.parse('$_apiURL/check-token?access_token=$_accessToken&refresh_token=$_refreshToken')).then<List<String>>((response) {
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
    final Uri url = Uri.parse('$_apiURL/login');
    print("$logTrace $url");

    return http.post(
      url,
      body: {
        'login': email,
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

  Future<String> register({String email, String phoneNumber, String password, String firstName, String lastName}) {
    final Uri url = Uri.parse('$_apiURL/users/register');
    print("$logTrace $url");

    return http.post(url,
        body: jsonEncode({
          'email': email,
          'password': password,
          'phoneNumber': phoneNumber,
          'name': {'first': firstName, 'last': lastName}
        }),
        headers: {'content-type': 'application/json'}).then<String>((response) {
      if (response.statusCode == 200) {
        return "Success";
        // Map<String, dynamic> data = jsonDecode(response.body);
        // String registrationToken = data['token'];
        // accessToken = registrationToken;
        // return registrationToken;
      }

      return Future.error(
        jsonDecode(response.body),
      );
    });
  }

  Future confirmPhoneNumber({
    String code,
  }) {
    final Uri url = Uri.parse('$_apiURL/users/confirm-account');
    print("$logTrace $url");

    return http.post(url,
        body: jsonEncode({
          'token': _accessToken,
          'code': code,
        }),
        headers: {'content-type': 'application/json'}).then((response) {
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        return data;
      }
      return Future.error(
        jsonDecode(response.body),
      );
    });
  }

  Future<List<Restaurant>> getRecommendedRestaurants({
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
    final url = Uri.parse('$_apiURL/RestoRecommander$query');
    print("$logTrace $url");

    return http.get(url).then<List<Restaurant>>((response) {
      if (response.statusCode == 200) {
        List<dynamic> list = jsonDecode(response.body);
        list.sort((a, b) => a["priority"].compareTo(b["priority"]));
        List<Restaurant> restaurants = list.map((data) => Restaurant.fromJson(data["restaurant"])).toList();
        return restaurants;
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
    final url = Uri.parse('$_apiURL/restaurants$query');
    print("$logTrace $url");

    return http.get(url).then<List<Restaurant>>((response) {
      if (response.statusCode == 200) {
        List<dynamic> list = jsonDecode(response.body);
        return list.map((data) => Restaurant.fromJson(data)).toList();
      }

      return Future.error(
        jsonDecode(response.body),
      );
    });
  }

  getRecommendedFoods(String lang, {Map<String, dynamic> filters, bool fromQrcode = false}) {
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

    final url = Uri.parse('$_apiURL/platRecommander$query');
    print("$logTrace $url");

    return http.get(
      url,
      headers: {
        "authorization": "Bearer $_accessToken",
      },
    ).then<List<Food>>((response) {
      if (response.statusCode == 200) {
        List<dynamic> list = jsonDecode(response.body);
        list.sort((a, b) => (a["priority"] as int).compareTo(b["priority"]));
        List<dynamic> listFoodMap = list.map((e) => e["food"]).toList();
        List<Food> foods = [];
        if (fromQrcode) {
          return listFoodMap.map((data) => Food.fromJson(data)).where((element) => element.status).toList();
        }
        foods = listFoodMap.map((data) => Food.fromJson(data)).where((element) => element.status && element.statut).toList();
        return foods;
      }

      return Future.error(
        jsonDecode(response.body),
      );
    });
  }

  Future<List<Food>> getFoods(String lang, {Map<String, dynamic> filters, bool fromQrcode = false}) {
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

    final url = Uri.parse('$_apiURL/foods$query');
    print("$logTrace $url");

    return http.get(
      url,
      headers: {
        "authorization": "Bearer $_accessToken",
      },
    ).then<List<Food>>((response) {
      if (response.statusCode == 200) {
        List<dynamic> list = jsonDecode(response.body);
        List<Food> foods = [];
        if (fromQrcode) {
          return list.map((data) => Food.fromJson(data)).where((element) => element.status).toList();
        }
        foods = list.map((data) => Food.fromJson(data)).where((element) => element.status && element.statut).toList();
        return foods;
      }

      return Future.error(
        jsonDecode(response.body),
      );
    });
  }

  Future<List<FoodCategory>> getFoodCategories(
    String lang,
  ) {
    final Uri url = Uri.parse('$_apiURL/foodCategories?lang=$lang');
    print("$logTrace $url");
    return http.get(url).then<List<FoodCategory>>((response) {
      if (response.statusCode == 200) {
        List<dynamic> list = jsonDecode(response.body);
        return list.map((data) => FoodCategory.fromJson(data)).toList();
      }

      return Future.error(
        jsonDecode(response.body),
      );
    });
  }

  Future<Food> getFood({
    String id,
    String lang,
  }) {
    final url = Uri.parse('$_apiURL/foods/$id?lang=$lang');
    print("$logTrace $url");
    return http.get(
      url,
      headers: {
        "authorization": "Bearer $_accessToken",
      },
    ).then<Food>((response) {
      print(response.body);
      if (response.statusCode == 200) return Food.fromJson(jsonDecode(response.body));

      return Future.error(
        jsonDecode(response.body),
      );
    });
  }

  Future<Restaurant> getRestaurant({
    String id,
    String lang,
  }) {
    final url = Uri.parse("$_apiURL/restaurants/$id?lang=$lang");
    print("$logTrace $url");
    return http.get(
      url,
      headers: {"authorization": "Bearer $_accessToken", 'content-type': 'application/json'},
    ).then<Restaurant>((response) {
      print(jsonDecode(response.body));
      Restaurant restaurant = Restaurant.fromJson(jsonDecode(response.body));
      print(restaurant);
      if (response.statusCode == 200) return restaurant;

      return Future.error(
        jsonDecode(response.body),
      );
    });
  }

  Future<bool> addToFavoriteFood(Food food) async {
    await _refreshTokens();
    final url = Uri.parse('$_apiURL/users/favoriteFoods');
    print("$logTrace $url");
    return http.post(url, body: {
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
    final url = Uri.parse('$_apiURL/users/favoriteFoods/${food.id}');
    print("$logTrace $url");
    return http.delete(url, headers: {
      "authorization": "Bearer $_accessToken",
    }).then((response) {
      if (response.statusCode == 200) return true;

      return false;
    });
  }

  Future<bool> addToFavoriteRestaurants(Restaurant restaurant) async {
    await _refreshTokens();
    final url = Uri.parse('$_apiURL/users/favoriteRestaurants');
    print("$logTrace $url");
    return http.post(url, body: {
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
    final url = Uri.parse('$_apiURL/users/favoriteRestaurants/${restaurant.id}');
    print("$logTrace $url");
    return http.delete(url, headers: {
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
    bool fromQrcode = false,
  }) {
    String searchQuery;

    if (location == null) {
      searchQuery = '?lang=$lang&q=$query&range=$range';
    } else {
      searchQuery = '?lang=$lang&q=$query&range=$range&location=${jsonEncode(location)}';
    }

    if (type is String) searchQuery += '&type=$type';
    if (filters != null && filters.length > 0) {
      var filterQuery = 'filter=${jsonEncode(filters)}';
      searchQuery += '&$filterQuery';
    }
    final url = Uri.parse('$_apiURL/search$searchQuery');
    print("$logTrace $url");

    return http.get(url).then<List<SearchResult>>((response) {
      if (response.statusCode == 200) {
        List<dynamic> results = jsonDecode(response.body);
        if (fromQrcode) {
          return results.map((e) => SearchResult.fromJson(e)).toList();
        } else {
          return results.map((e) => SearchResult.fromJson(e)).where((element) => element.content['status'] ?? true).toList();
        }
      }
      return Future.error(
        jsonDecode(response.body),
      );
    });
  }

  Future<String> getRestaurantName({String id}) {
    final url = Uri.parse('$_apiURL/restaurants/$id/name');
    print("$logTrace $url");

    return http.get(url).then<String>((response) {
      if (response.statusCode == 200) {
        return response.body;
      }

      return Future.error(
        jsonDecode(response.body),
      );
    });
  }

  Future<String> resetPassword(String phoneNumber) {
    final url = Uri.parse('$_apiURL/users/reset-password');
    print("$logTrace $url");

    return http.post(url, body: {
      'phoneNumber': phoneNumber,
    }).then<String>((response) {
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        return data['token'];
      }

      return Future.error(
        jsonDecode(response.body),
      );
    });
  }

  Future<bool> confirmResetPassword({
    String token,
    int code,
    String password,
  }) {
    final url = Uri.parse('$_apiURL/users/confirm-reset-password');
    print("$logTrace $url");

    return http.post(url, body: {
      'token': token,
      'code': code.toString(),
      'password': password,
    }).then<bool>((response) {
      if (response.statusCode == 200) return true;

      return false;
    });
  }

  Future<User> getMe() async {
    await _refreshTokens();
    final url = Uri.parse('$_apiURL/users/me');
    print("$logTrace $url");

    return http.get(url, headers: {
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
    final url = Uri.parse('$_apiURL/users/paymentCards');
    print("$logTrace $url");

    return http.post(url, body: paymentCard.toJson().map<String, String>((key, value) => MapEntry(key, value.toString())), headers: {
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

  Future<List<Menu>> getMenus(String lang, String id, {bool fromCommand = true}) {
    ///@deprecated
    // final url = Uri.parse('$_apiURL/restaurants/$id/menus?lang=$lang');
    final url = Uri.parse("$_apiURL/restaurants/pages/$id?lang=$lang");
    print("$logTrace $url");

    return http.get(url).then<List<Menu>>(
      (response) {
        print("$_apiURL/restaurants/pages/$id?lang=$lang");
        if (response.statusCode == 200) {
          final datas = jsonDecode(response.body);
          return datas["menu"]?.map<Menu>((e) => Menu.fromJson(e, fromCommand: fromCommand))?.toList() ?? [];
        }

        return Future.error(
          jsonDecode(response.body),
        );
      },
    );
  }

  Future<Menu> getMenu(String id) {
    final url = Uri.parse('$_apiURL/menus/$id');
    print("$logTrace $url");

    return http.get(url).then<Menu>(
      // Future<List<Menu>> getMenus(String lang, String id) => http.get('$_apiURL/restaurants/$id/menus').then<List<Menu>>(
      (response) {
        print("$_apiURL/menus/$id");
        if (response.statusCode == 200) {
          var menu = jsonDecode(response.body);
          return Menu.fromJson(menu);
        }

        return Future.error(
          jsonDecode(response.body),
        );
      },
    );
  }

  Future updatePassword(String oldPassword, String newPassword) async {
    await _refreshTokens();
    final url = Uri.parse('$_apiURL/users/update-password');
    print("$logTrace $url");

    return http.post(url, body: {
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
    final url = Uri.parse('$_apiURL/users/paymentCards/${creditCard.id}');
    print("$logTrace $url");

    return http.delete(url, headers: {
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
    final url = Uri.parse('$_apiURL/users/$id');
    print("$logTrace $url");

    return http
        .put(
      url,
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
    String commandType,
  }) async {
    await _refreshTokens();
    String filter;

    if (commandType != null) {
      filter = 'filter={"relatedUser": "${user.id}","commandType":$commandType}';
    } else {
      filter = 'filter={"relatedUser": "${user.id}"}';
    }
    final url = Uri.parse('$_apiURL/commands?$filter&offset=$offset${limit != null ? '&limit=$limit' : ''}');
    print("$logTrace $url");

    return http.get(url, headers: {
      'authorization': 'Bearer $_accessToken',
      'Content-Type': 'application/json',
    }).then<List<Command>>((response) {
      if (response.statusCode == 200) {
        List datas = jsonDecode(response.body);
        return datas.map<Command>((data) => Command.fromJson(data)).toList();
      }

      // return Future.error(jsonDecode(response.body));
      return [];
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
    String comment,
    bool priceless,
    String optionLivraison = 'out',
    String appartement,
    String codeappartement,
    int etage,
    bool payed = false,
    bool paiementLivraison = false,
    bool isDelivery = false,
    String priceLivraison,
  }) async {
    await _refreshTokens();
    try {
      var post;
      if (isDelivery) {
        post = jsonEncode({
          'relatedUser': relatedUser,
          'commandType': commandType,
          'totalPrice': totalPrice.toString(),
          'restaurant': restaurant,
          'items': items,
          'shippingTime': shippingTime,
          'shippingAddress': shippingAddress,
          'shipAsSoonAsPossible': shipAsSoonAsPossible,
          'customer': customer,
          'menus': menu,
          'comment': comment,
          'priceless': priceless,
          'optionLivraison': optionLivraison,
          'appartement': appartement,
          'codeAppartement': codeappartement,
          'etage': etage,
          'payed': payed,
          'paiementLivraison': paiementLivraison,
          'priceLivraison': priceLivraison,
        });
      } else {
        post = jsonEncode({
          'relatedUser': relatedUser,
          'commandType': commandType,
          'totalPrice': totalPrice.toString(),
          'restaurant': restaurant,
          'items': items,
          'shippingTime': shippingTime,
          'shippingAddress': shippingAddress,
          'shipAsSoonAsPossible': shipAsSoonAsPossible,
          'customer': customer,
          'menus': menu,
          'comment': comment,
          'priceless': priceless,
        });
      }

      final url = Uri.parse('$_apiURL/commands');
      print("$logTrace $url");

      print(post);
      return http
          .post(
        url,
        headers: {
          'authorization': 'Bearer $_accessToken',
          'Content-type': 'application/json',
        },
        body: post,
      )
          .then<Map>((response) async {
        if (response.statusCode != 200)
          return Future.error(
            jsonDecode(response.body),
          );

        return jsonDecode(response.body);
      });
    } catch (error) {
      throw error;
    }
  }

  Future getCommand(String idCommande) {
    final url = Uri.parse("$_apiURL/commands/$idCommande");
    return http.get(url, headers: {
      'content-type': 'application/json',
      "authorization": "Bearer $_accessToken",
    }).then((response) => (response.statusCode != 200) ? Future.error(jsonDecode(response.body)) : jsonDecode(response.body));
  }

  Future setCommandToPayedStatus(
    bool status, {
    String id,
    String paymentIntentId,
  }) async {
    await _refreshTokens();
    final url = Uri.parse('$_apiURL/commands/$id');
    print("$logTrace $url");

    return http
        .put(
      url,
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'Content-type': 'application/json',
      },
      body: jsonEncode(
        {
          'payed': {
            'status': status,
            'paymentIntentId': paymentIntentId,
          }
        },
      ),
    )
        .then((response) {
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return Future.error(jsonDecode(response.body));
    });
  }

  Future<FoodAttribute> getFoodAttribute({String id}) async {
    await _refreshTokens();
    final url = Uri.parse('$_apiURL/foodAttributes/$id');
    print("$logTrace $url");

    return http.get(url, headers: {
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
    final url = Uri.parse('$_apiURL/foodAttributes');
    print("$logTrace $url");

    return http.get(url, headers: {
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
    final geoUrl = Uri.parse("https://nominatim.openstreetmap.org/reverse?format=geojson&lat=$latitude&lon=$longitude");
    print("$logTrace $geoUrl");

    return http.get(geoUrl).then((value) {
      Placemark data = Placemark.fromJson(json.decode(value.body));
      // var js = json.decode(value.body);
      String city = data.features.first.properties.address.city;
      return city;
    }).catchError((onError) {
      throw onError.toString();
    });
  }

  Future<bool> sendMessage(Message message) async {
    await _refreshTokens();
    final url = Uri.parse('$_apiURL/messages');
    print("$logTrace $url");

    return http.post(url, body: json.encode(message.toJson()), headers: {'content-type': 'application/json'}).then((response) {
      if (response.statusCode == 200) return true;
      print(jsonDecode(response.body));
      return false;
    });
  }

  Future<List<Blog>> getBlog() async {
    // await _refreshTokens();
    final url = Uri.parse('$_apiURL/posts');
    print("$logTrace $url");

    return http.get(url, headers: {
      'Content-Type': 'application/json',
    }).then<List<Blog>>((response) {
      if (response.statusCode == 200) {
        List datas = jsonDecode(response.body);
        return datas.map<Blog>((data) => Blog.fromJson(data)).toList();
      }
      return Future.error(jsonDecode(response.body));
    });
  }

  Future<Map<String, dynamic>> ConfirmSms(String idCommande, String code, String commandType) async {
    await _refreshTokens();
    final url = Uri.parse('$_apiURL/commands/$idCommande/confirm');
    print("$logTrace $url");

    return http.post(url, body: json.encode({'code': code, 'commandType': commandType}), headers: {
      'content-type': 'application/json',
      "authorization": "Bearer $_accessToken",
    }).then((response) {
      if (response.statusCode == 200) return jsonDecode(response.body);
      print(jsonDecode(response.body));
      return jsonDecode(response.body);
    });
  }

  Future<String> sendCode({@required String relatedUser, @required Map customer, @required String commandType}) {
    var post = jsonEncode({
      'relatedUser': relatedUser,
      'commandType': commandType,
      'customer': customer,
    });
    final url = Uri.parse('$_apiURL/commands/sendCode');
    print("$logTrace $url");

    print(post);
    return http
        .post(
      url,
      headers: {
        'Content-type': 'application/json',
      },
      body: post,
    )
        .then((value) {
      var response = jsonDecode(value.body);
      return "${response["code"]}";
    });
  }

  Future<bool> confirmCode({
    @required String relatedUser,
    @required Map customer,
    @required String code,
    @required String commandType,
  }) {
    var post = jsonEncode({
      'relatedUser': relatedUser,
      'commandType': commandType,
      'customer': customer,
      'code': code,
    });
    final url = Uri.parse('$_apiURL/commands/confirmCode');
    print("$logTrace $url");

    print(post);
    return http
        .post(
      url,
      headers: {
        'Content-type': 'application/json',
      },
      body: post,
    )
        .then((value) {
      print("confirmCode $value");
      return true;
    });
  }

  Future<List<FoodType>> getFoodTypesByRestaurantId(String restaurantId) {
    final url = Uri.parse('$_apiURL/foodTypes');
    print("$logTrace $url");

    return http.get(url).then<List<FoodType>>((response) {
      if (response.statusCode == 200) {
        final list = jsonDecode(response.body);
        final List<FoodType> foodTypes = list.map<FoodType>((data) => FoodType.fromJson(data)).toList();
        return foodTypes.where((e) => e?.restaurant?.id == restaurantId).toList();
      }
      return [];
    });
  }

  Future<List<FoodType>> getFoodTypes() {
    final url = Uri.parse('$_apiURL/foodTypes');
    print("$logTrace $url");

    return http.get(url).then<List<FoodType>>((response) {
      if (response.statusCode == 200) {
        var list = jsonDecode(response.body);
        return list.map<FoodType>((data) => FoodType.fromJson(data)).toList();
      }

      return [];
    });
  }
}
