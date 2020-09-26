import 'package:flutter/material.dart';
import 'package:menu_advisor/src/models.dart';
import 'package:menu_advisor/src/services/api.dart';

class DataContext extends ChangeNotifier {
  List<Food> popularFoods = [];
  bool loadingPopularFoods = false;
  List<Restaurant> nearestRestaurants = [];
  bool loadingNeareseRestaurants = false;

  final Api _api = Api.instance;

  DataContext() {
    _fetchNearestRestaurants();
    _fetchPopularFoods();
  }

  _fetchNearestRestaurants() async {
    loadingNeareseRestaurants = true;
    notifyListeners();
    try {
      nearestRestaurants = await _api.getRestaurants(
        filters: {"searchCategory": "nearest"},
      );
    } catch (error) {}
    loadingNeareseRestaurants = false;
    notifyListeners();
  }

  _fetchPopularFoods() async {}

  void fetchFoods() {}
}
