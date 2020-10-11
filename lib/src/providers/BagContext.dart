import 'package:flutter/material.dart';
import 'package:menu_advisor/src/models.dart';

class BagContext extends ChangeNotifier {
  Map<Food, int> _items = Map();
  int _itemCount = 0;
  bool pricelessItems = false;
  String _commandType = 'delivery';

  String get commandType => _commandType;

  void set commandType(String value) {
    _commandType = value;
    notifyListeners();
  }

  bool addItem(Food item, number) {
    if (_itemCount == 0 ||
        (pricelessItems && item.price == null) ||
        (!pricelessItems && item.price != null)) {
      _itemCount++;
      _items.update(
        item,
        (value) => number,
        ifAbsent: () => number,
      );
      pricelessItems = item.price == null;
      notifyListeners();
      return true;
    }

    return false;
  }

  Map<Food, int> get items => _items;

  int get itemCount => _itemCount;

  double get totalPrice {
    double totalPrice = 0;

    _items.forEach((food, count) {
      if (food.price != null && food.price.amount != null)
        totalPrice += food.price.amount / 100 * count;
    });

    return totalPrice;
  }

  bool contains(Food food) {
    return _itemCount > 0 &&
        _items.keys.firstWhere(
              (element) => element.id == food.id,
              orElse: () => null,
            ) !=
            null;
  }

  void removeItem(Food food) {
    _items.removeWhere((key, _) => key.id == food.id);
    _itemCount--;
    notifyListeners();
  }

  void setCount(Food food, int itemCount) {
    _items.updateAll((key, value) {
      if (key.id == food.id) return itemCount;
      return value;
    });
    notifyListeners();
  }

  int getCount(Food food) {
    int count = 0;
    _items.forEach((key, value) {
      if (key.id == food.id) count = value;
    });
    return count;
  }

  void clear() {
    _items.clear();
    _itemCount = 0;
    notifyListeners();
  }
}
