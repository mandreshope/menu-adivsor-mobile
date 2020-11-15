import 'package:flutter/material.dart';
import 'package:menu_advisor/src/models.dart';

class CartContext extends ChangeNotifier {
  Map<dynamic, int> _items = Map();
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

  bool hasSameOriginAsInBag(dynamic item) => 
  currentOrigin == null || item.restaurant == currentOrigin;

  bool hasSamePricingAsInBag(dynamic item) => 
  (pricelessItems && (item.price == null || item.price.amount == null)) || (!pricelessItems && item.price != null && item.price.amount != null);

  bool addItem(dynamic item, number) {
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

  Map<dynamic, int> get items => _items;

  int get itemCount => _items.length;

  double get totalPrice {
    double totalPrice = 0;

    _items.forEach((food, count) {
      /*if (food.isMenu) {
        food.foods.forEach((f){
         if (f.price != null && f.price.amount != null) totalPrice += f.price.amount / 100 * count;
        });
      }else*/
      if (food.price != null && food.price.amount != null) totalPrice += food.price.amount / 100 * count;
    });

    return totalPrice;
  }

  bool contains(dynamic food) {
    return itemCount > 0 &&
        _items.keys.firstWhere(
              (element) => element.id == food.id,
              orElse: () => null,
            ) !=
            null;
  }

  void removeItem(dynamic food) {
    _items.removeWhere((key, _) => key.id == food.id);
    if (_items.length == 0) currentOrigin = null;
    notifyListeners();
  }

  void setCount(dynamic food, int itemCount) {
    _items.updateAll((key, value) {
      if (key.id == food.id) return itemCount;
      return value;
    });
    notifyListeners();
  }

  int getCount(dynamic food) {
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
