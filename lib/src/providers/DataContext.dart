import 'package:flutter/material.dart';
import 'package:menu_advisor/src/models.dart';
import 'package:menu_advisor/src/services/api.dart';

class DataContext extends ChangeNotifier {
  List<Food> popularFoods = [];
  bool loadingPopularFoods = false;

  List<Restaurant> popularRestaurants = [];
  bool loadingNearestRestaurants = false;

  List<Food> foods = [];
  bool loadingFoods = false;

  final Api _api = Api.instance;

  DataContext() {
    _fetchPopularRestaurants();
    _fetchPopularFoods();
  }

  Future refresh() async {
    loadingPopularFoods = true;
    loadingNearestRestaurants = true;
    notifyListeners();

    await _fetchPopularFoods();
    loadingPopularFoods = false;
    notifyListeners();

    await _fetchPopularRestaurants();
    loadingNearestRestaurants = false;
    notifyListeners();
  }

  _fetchPopularRestaurants() async {
    loadingNearestRestaurants = true;
    notifyListeners();
    try {
      popularRestaurants = await _api.getRestaurants(
        filters: {"searchCategory": "popular"},
      );
    } catch (error) {
      print("Error while fetching popular restaurants");
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
        filters: {"searchCategory": "popular"},
      );
    } catch (error) {
      print(error);
    }
    loadingPopularFoods = false;
    notifyListeners();
    return;
  }

  fetchFoods(Map<String, dynamic> filters) async {
    loadingFoods = true;
    notifyListeners();

    try {
      foods = await _api.getFoods(filters: filters);
    } catch (error) {
      print('Error while fetching foods...');
      print('$error');
    }

    loadingFoods = false;
    notifyListeners();
    return;
  }
}
