import 'package:flutter/material.dart';

class RestaurantContext with ChangeNotifier {
  int _currentIndex = 0;
  List<FoodTypeItem> foodTypes = [];

  set currentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  get currentIndex => _currentIndex;

  setFoodTypeSelected(position) {
    foodTypes.forEach((element) {
      if (element.name == foodTypes[position].name)
        element.isSelected = true;
      else
        element.isSelected = false;
    });
    notifyListeners();
  }

  init(dynamic types) {
    foodTypes.clear();
    for (int i = 0; i < types.length; i++) {
      if (types[i].tag != 'drink') {
        foodTypes.add(FoodTypeItem(name: types[i].name));
        // _segmentChilder[i] = _segmentWidget(restaurant.foodTypes[i]['name']['fr']);
      }
    }
    foodTypes[0].isSelected = true;
    // notifyListeners();
  }
}

class FoodTypeItem {
  String name;
  bool isSelected;

  FoodTypeItem({this.name, this.isSelected = false});
}
