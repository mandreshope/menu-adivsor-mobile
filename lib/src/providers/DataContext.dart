import 'package:flutter/material.dart';
import 'package:menu_advisor/src/models.dart';
import 'package:menu_advisor/src/services/api.dart';

class DataContext extends ChangeNotifier {
  List<Food> popularFoods = [];
  bool loadingPopularFoods = false;
  List<Restaurant> popularRestaurants = [];
  bool loadingNeareseRestaurants = false;

  final Api _api = Api.instance;

  DataContext() {
    _fetchPopularRestaurants();
    _fetchPopularFoods();
  }

  Future refresh() async {
    loadingPopularFoods = true;
    notifyListeners();
    await _fetchPopularFoods();
    loadingPopularFoods = false;
    notifyListeners();

    loadingNeareseRestaurants = true;
    notifyListeners();
    await _fetchPopularRestaurants();
    loadingNeareseRestaurants = false;
    notifyListeners();
  }

  _fetchPopularRestaurants() async {
    loadingNeareseRestaurants = true;
    notifyListeners();
    try {
      popularRestaurants = await _api.getRestaurants(
        filters: {"searchCategory": "popular"},
      );
    } catch (error) {
      print(error);
    }
    loadingNeareseRestaurants = false;
    notifyListeners();
  }

  _fetchPopularFoods() async {}

  void fetchFoods() {}
}
