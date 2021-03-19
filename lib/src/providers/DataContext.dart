import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:menu_advisor/src/models.dart';
import 'package:menu_advisor/src/services/api.dart';
import 'package:menu_advisor/src/types.dart';

class DataContext extends ChangeNotifier {
  List<Food> popularFoods = [];
  bool loadingPopularFoods = true;

  List<Restaurant> nearestRestaurants = [];
  bool loadingNearestRestaurants = true;

  List<FoodCategory> foodCategories = [];
  bool loadingFoodCategories = true;

  List<Food> onSiteFoods = [];
  bool loadingOnSiteFoods = true;

  List<Food> foods = [];
  bool loadingFoods = true;

  List<FoodAttribute> _foodAttributes = List();

  List<Blog> blogs = List();
  bool loadingBlog = true;
  bool isAllAttribute = false;

  /*List<Map<String, String>> attributes = [
    {
      'tag': 'allergen_egg',
      'fr': 'Oeufs',
      'en': 'Eggs',
      'imageURL':
          'https://www.menu-touch.fr/resto/webmenu/v1.0/images/allergens/allergen_egg.png',
    },
    {
      'tag': 'allergen_gluten',
      'fr': 'Gluten',
      'en': 'Gluten',
      'imageURL':
          'https://www.menu-touch.fr/resto/webmenu/v1.0/images/allergens/allergen_gluten.png',
    },
    {
      'tag': 'allergen_crustacean',
      'fr': 'Crustacé',
      'en': 'Crustacean',
      'imageURL':
          'https://www.menu-touch.fr/resto/webmenu/v1.0/images/allergens/allergen_crustacean.png',
    },
  ];*/

  List<FoodAttribute> attributes = List();
  bool loadingFoodAttributes = false;

  final Api _api = Api.instance;


  String _city = "";

  List<FoodType> foodTypes = [];

  setCity(double latitude, double longitude) async {
    _city = await _api.getCityFromCoordinates(latitude, longitude);
  }

  String getCity() => _city;

  DataContext(){
    _fetchAttributes();
    _fetchFoodType();
  }

  Future refresh(String lang, Location location) async {
    loadingFoodCategories = true;
    loadingPopularFoods = true;
    loadingNearestRestaurants = true;
    loadingOnSiteFoods = true;
    loadingFoodAttributes = true;
    loadingBlog = true;
    notifyListeners();

    await _fetchNearestRestaurants(location,lang);

    await _fetchFoodCategories(lang);

    await _fetchPopularFoods(location,lang);

    await _fetchOnSiteFoods(lang);

    await _fetchBlog();
  }

  _fetchFoodCategories(String lang) async {
    loadingFoodCategories = true;
    notifyListeners();
    try {
      foodCategories = await _api.getFoodCategories(lang);
    } catch (error) {
      print(
        "Error while fetching food categories",
      );
      print(error);
    } finally {
      loadingFoodCategories = false;
      notifyListeners();
    }
  }

  _fetchNearestRestaurants(Location location,lang) async {
    loadingNearestRestaurants = true;
    notifyListeners();

    try {
      nearestRestaurants.clear();
      List<Restaurant> temp = await _api.getRestaurants(
        filters: {
          "searchCategory": "priority",
          "location": "${jsonEncode(location)}",
          // "city":_city
          // 'NEAREST': 'nearest',
        },
      );
      // _searchResult.take(5).forEach((e) {
      //   nearestRestaurants.add(Restaurant.fromJson(e.content));
      // });
      // nearestRestaurants.reversed;
      nearestRestaurants = temp.where((element) => element.status).toList();
    } catch (error) {
      print(
        "Error while fetching popular restaurants",
      );
      print(error);
    } finally {
      loadingNearestRestaurants = false;
      notifyListeners();
    }
  }

  _fetchPopularFoods(Location location,String lang) async {
    loadingPopularFoods = true;
    notifyListeners();

    try {
      popularFoods.clear();
      List<Food> _popularFoods = await _api.getFoods(
        // "",
        lang,
        filters: {
          "searchCategory": "priority",
          "location": "${jsonEncode(location)}",
          // "searchCategory": "with_price",
          // "limit": 5,
          // "city":""
        },
        // type: 'food'
      );
      _popularFoods.forEach((element) {
        element.isPopular = true;
      });
      popularFoods = _popularFoods.where((element) => element.status && element.statut).toList();
      // _searchResult.take(5).forEach((e) {
      //   popularFoods.add(Food.fromJson(e.content));
      // });
    } catch (error) {
      print(error);
    } finally {
      loadingPopularFoods = false;
      notifyListeners();
    }
  }

  _fetchOnSiteFoods(String lang) async {
    loadingOnSiteFoods = true;
    notifyListeners();

    try {
      // onSiteFoods.clear();
      List<Food> _onSiteFoods = await _api.getFoods(
        // "",
        lang,
        // type: 'food',
        filters: {
          "searchCategory": "onsite",
          // "limit": 5,
          // "city":_city,
          // "price.amount":null
        },
      );
      onSiteFoods = _onSiteFoods.where((element) => element.status).toList();
      // _searchResult.take(5).forEach((e) {
      //   onSiteFoods.add(Food.fromJson(e.content));
      // });
    } catch (error) {
      print("Error while fetching on site foods");
      print(error);
    } finally {
      loadingOnSiteFoods = false;
      notifyListeners();
    }
  }

  fetchFoods(String lang, Map<String, dynamic> filters) async {
    loadingFoods = true;
    notifyListeners();

    try {
      List<Food> _foods = await _api.getFoods(lang, filters: filters);
      foods = _foods.where((element) => element.status).toList();
    } catch (error) {
      print(
        'Error while fetching foods...',
      );
      print('$error');
    }

    loadingFoods = false;
    notifyListeners();
    return;
  }

  fetchFoodAttributes(List<String> id) async {
    /*loadingFoodAttributes = true;
    notifyListeners();*/
    try {
      attributes.clear();
      id.forEach((element) async {
        String e = element.replaceFirst("_", "");
        attributes.add(FoodAttribute.fromJson(jsonDecode(e)));
      });
    }catch (error) {
      print(
        'Error while  fetchFoodAttribute...',
      );
      print('$error');
    }
   loadingFoodAttributes = false;
    notifyListeners();
  }

  _fetchAttributes() async {
    _foodAttributes = await _api.getFoodAttributes(); 
  }

  _fetchFoodType() async {
    foodTypes = await _api.getFoodTypes(); 
  }

  List<FoodAttribute> get foodAttributes => _foodAttributes;

  _fetchBlog() async {
    blogs = await _api.getBlog();
    loadingBlog = false;
    notifyListeners();
  }

  resetAttributes() {
    _foodAttributes.forEach((element) {
        element.isChecked = false;
    });
  }

}
