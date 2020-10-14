import 'package:flutter/material.dart';
import 'package:menu_advisor/src/models.dart';
import 'package:menu_advisor/src/services/api.dart';
import 'package:menu_advisor/src/types.dart';

class DataContext extends ChangeNotifier {
  List<Food> popularFoods = [];
  bool loadingPopularFoods = false;

  List<Restaurant> nearestRestaurants = [];
  bool loadingNearestRestaurants = false;

  List<FoodCategory> foodCategories = [];
  bool loadingFoodCategories = false;

  List<Food> onSiteFoods = [];
  bool loadingOnSiteFoods = false;

  List<Food> foods = [];
  bool loadingFoods = false;

  List<Map<String, String>> attributes = [
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
  ];

  final Api _api = Api.instance;

  Future refresh(String lang, Location location) async {
    loadingFoodCategories = true;
    loadingPopularFoods = true;
    loadingNearestRestaurants = true;
    loadingOnSiteFoods = true;
    notifyListeners();

    await _fetchFoodCategories(lang);

    await _fetchPopularFoods(lang);

    await _fetchNearestRestaurants(location);

    await _fetchOnSiteFoods(lang);
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

  _fetchNearestRestaurants(Location location) async {
    loadingNearestRestaurants = true;
    notifyListeners();

    try {
      nearestRestaurants = await _api.getRestaurants(
        filters: {
          "searchCategory": "nearest",
          "location": location.toString(),
        },
      );
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

  _fetchPopularFoods(String lang) async {
    loadingPopularFoods = true;
    notifyListeners();

    try {
      popularFoods = await _api.getFoods(
        lang,
        filters: {
          "searchCategory": "popular",
          "limit": 5,
        },
      );
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
      onSiteFoods = await _api.getFoods(
        lang,
        filters: {
          "searchCategory": "onsite",
          "limit": 5,
        },
      );
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
      foods = await _api.getFoods(lang, filters: filters);
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
}
