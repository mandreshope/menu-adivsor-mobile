import 'package:flutter/material.dart';
import 'package:menu_advisor/src/models.dart';
import 'package:menu_advisor/src/services/api.dart';

class DataContext extends ChangeNotifier {
  List<Food> popularFoods = [];
  bool loadingPopularFoods = false;
  List<Restaurant> popularRestaurants = [];
  bool loadingPopularRestaurants = false;

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

    loadingPopularRestaurants = true;
    notifyListeners();
    await _fetchPopularRestaurants();
    loadingPopularRestaurants = false;
    notifyListeners();
  }

  _fetchPopularRestaurants() async {
    loadingPopularRestaurants = true;
    notifyListeners();
    try {
      popularRestaurants = await _api.getRestaurants(
        filters: {"searchCategory": "popular"},
      );
    } catch (error) {
      print('Error while fetching popular restaurants: $error');
    } finally {
      loadingPopularRestaurants = false;
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
      print('Error while fetching popular foods: $error');
    } finally {
      loadingPopularFoods = false;
      notifyListeners();
    }
  }

  void fetchFoods() {}
}
