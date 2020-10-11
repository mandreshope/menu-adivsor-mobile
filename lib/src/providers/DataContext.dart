import 'package:flutter/material.dart';
import 'package:menu_advisor/src/models.dart';
import 'package:menu_advisor/src/services/api.dart';

class DataContext extends ChangeNotifier {
  List<Food> popularFoods = [];
  bool loadingPopularFoods = false;

  List<Restaurant> popularRestaurants = [];
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
      'image': 'assets/images/allergen_egg.png',
    },
    {
      'tag': 'allergen_gluten',
      'fr': 'Gluten',
      'en': 'Gluten',
      'image': 'assets/images/allergen_gluten.png',
    },
    {
      'tag': 'allergen_crustacean',
      'fr': 'Crustacé',
      'en': 'Crustacean',
      'image': 'assets/images/allergen_crustacean.png',
    },
  ];

  final Api _api = Api.instance;

  DataContext() {
    _fetchFoodCategories();
    _fetchPopularRestaurants();
    _fetchPopularFoods();
    _fetchOnSiteFoods();
  }

  Future refresh() async {
    loadingFoodCategories = true;
    loadingPopularFoods = true;
    loadingNearestRestaurants = true;
    loadingOnSiteFoods = true;
    notifyListeners();

    await _fetchFoodCategories();

    await _fetchPopularFoods();

    await _fetchPopularRestaurants();
  }

  _fetchFoodCategories() async {
    loadingFoodCategories = true;
    notifyListeners();
    try {
      foodCategories = await _api.getFoodCategories();
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

  _fetchPopularRestaurants() async {
    loadingNearestRestaurants = true;
    notifyListeners();

    try {
      popularRestaurants = await _api.getRestaurants(
        filters: {
          "searchCategory": "popular",
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

  _fetchPopularFoods() async {
    loadingPopularFoods = true;
    notifyListeners();

    try {
      popularFoods = await _api.getFoods(
        filters: {
          "searchCategory": "popular",
        },
      );
    } catch (error) {
      print(error);
    } finally {
      loadingPopularFoods = false;
      notifyListeners();
    }
  }

  _fetchOnSiteFoods() async {
    loadingOnSiteFoods = true;
    notifyListeners();

    try {
      onSiteFoods = await _api.getFoods(
        filters: {
          "searchCategory": "onsite",
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

  fetchFoods(Map<String, dynamic> filters) async {
    loadingFoods = true;
    notifyListeners();

    try {
      foods = await _api.getFoods(filters: filters);
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
