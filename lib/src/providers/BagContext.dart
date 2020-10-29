import 'package:flutter/material.dart';
import 'package:menu_advisor/src/models.dart';

class CartContext extends ChangeNotifier {
  Map<Food, int> _items = Map();
  String _currentOrigin;

  String get currentOrigin => _currentOrigin;

  set currentOrigin(String currentOrigin) {
    _currentOrigin = currentOrigin;
    notifyListeners();
  }

  bool get pricelessItems {
    return _items.keys.length > 0 &&
        _items.keys.any(
          (element) => element.price == null || element.price.amount == null,
        );
  }

  bool hasSameOriginAsInBag(Food item) => currentOrigin == null || item.restaurant == currentOrigin;

  bool hasSamePricingAsInBag(Food item) => (pricelessItems && (item.price == null || item.price.amount == null)) || (!pricelessItems && item.price != null && item.price.amount != null);

  bool addItem(Food item, number) {
    if (itemCount == 0 || (hasSamePricingAsInBag(item) && hasSameOriginAsInBag(item))) {
      _items.update(
        item,
        (value) => number,
        ifAbsent: () => number,
      );
      currentOrigin = item.restaurant;
      notifyListeners();
      return true;
    }

    return false;
  }

  Map<Food, int> get items => _items;

  int get itemCount => _items.length;

  double get totalPrice {
    double totalPrice = 0;

    _items.forEach((food, count) {
      if (food.price != null && food.price.amount != null) totalPrice += food.price.amount / 100 * count;
    });

    return totalPrice;
  }

  bool contains(Food food) {
    return itemCount > 0 &&
        _items.keys.firstWhere(
              (element) => element.id == food.id,
              orElse: () => null,
            ) !=
            null;
  }

  void removeItem(Food food) {
    _items.removeWhere((key, _) => key.id == food.id);
    if (_items.length == 0) currentOrigin = null;
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
    _currentOrigin = null;
    notifyListeners();
  }
}
