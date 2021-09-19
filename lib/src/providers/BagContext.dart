import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:menu_advisor/src/models/models.dart';

class CartContext extends ChangeNotifier {
  // Map<dynamic, int> _items = Map();
  List<dynamic> _items = [];
  List<dynamic> _itemsTemp = [];

  Map<String, List<List<Option>>> _options = Map();

  String _currentOrigin;
  Queue q = Queue();
  String comment = "";
  bool withPrice = true;

  Map<String, Food> _foodMenuSelected = Map();

  // Food _foodMenuSelected;
  setFoodMenuSelected(String key, value) {
    _foodMenuSelected[key] = value;
    _foodMenuSelected[key].isMenu = true;
  }

  Map<String, Food> get foodMenuSelected => _foodMenuSelected;
  List<Food> get foodMenuSelecteds {
    List<Food> foods = [];
    _foodMenuSelected.forEach((key, value) {
      foods.add(value);
    });

    return foods;
  }

  String get currentOrigin => _currentOrigin;

  set currentOrigin(String currentOrigin) {
    _currentOrigin = currentOrigin;
    notifyListeners();
  }

  bool get pricelessItems {
    /*return _items.keys.length > 0 &&
        _items.keys.any(
          (element) => element.price == null || element.price.amount == null,
        );*/
    return _items.length > 0 &&
        _items.any(
          (element) => element.price == null || element.price.amount == null,
        );
  }

  bool hasSameOriginAsInBag(dynamic item) => currentOrigin == null || ((item.restaurant is String) ? item.restaurant : item.restaurant['_id']) == currentOrigin;

  bool hasSamePricingAsInBag(dynamic item) =>
      !withPrice ? true : (pricelessItems && (item.price == null || item.price.amount == null)) || (!pricelessItems && item.price != null && item.price.amount != null);

  bool addItem(dynamic item, number, bool isAdd) {
    if (itemCount == 0 || (hasSamePricingAsInBag(item) && hasSameOriginAsInBag(item))) {
      if (isAdd) {
        _items.add(item);
      } else {
        removeItem(item);
      }
      // _itemsTemp.sort((a, b) => a.name.compareTo(b.name));

      currentOrigin = (item.restaurant is String)
          ? item.restaurant
          : item is Menu
              ? item.restaurant.id
              : item.restaurant['_id'];
      notifyListeners();
      return true;
    }

    return false;
  }

  void addAllItem() {
    _items.addAll(_itemsTemp);
    _items.sort((a, b) => a.name.compareTo(b.name));
    _itemsTemp.clear();
    notifyListeners();
  }

  /*bool removeFoodItemMenu(String idFood,String idOption){
    _items.forEach((food, count) {
      if(food.isFoodForMenu){
        food.optionSelected.forEach((f){
          if (f.sId == idOption)
            f.itemOptionSelected.clear();
        });
      }
    });
  }*/

  // Map<dynamic, int> get items => _items;
  List<dynamic> get items => _items;
  List<dynamic> get itemsTemp => _itemsTemp;
  // Map<dynamic, List<List<Option>>> get options => _options;

  int get itemCount => _items.length;

  double get totalPrice {
    if (!withPrice) return 0;
    double totalPrice = 0;

    _items.forEach((food) {
      totalPrice += food.totalPrice.toDouble() / 100;
    });
    List<Option> _temp = _options.values.expand((element) => element).toList().expand((element) => element).toList();
    _temp.forEach((option) {
      option.itemOptionSelected?.forEach((itemOption) {
        if (itemOption.price != null && itemOption.price.amount != null) totalPrice += itemOption.price.amount / 100 * itemOption.quantity;
      });
    });

    return totalPrice;
  }

  bool contains(dynamic food) {
    if (food.isFoodForMenu)
      return _items.firstWhere(
            (element) => (element.id == food.id && element.idMenu == food.idMenu),
            orElse: () => null,
          ) !=
          null;

    return itemCount > 0 &&
        _items.firstWhere(
              (element) => (element.id == food.id && !food.isFoodForMenu),
              orElse: () => null,
            ) !=
            null;
  }

  bool containsTemp(dynamic food) {
    if (food.isFoodForMenu)
      return _itemsTemp.firstWhere(
            (element) => (element.id == food.id && element.idMenu == food.idMenu),
            orElse: () => null,
          ) !=
          null;

    return _itemsTemp.firstWhere(
          (element) => (element.id == food.id && !food.isFoodForMenu),
          orElse: () => null,
        ) !=
        null;
  }

  void removeItem(dynamic food) {
    dynamic item;

    if (food is Food) {
      if (food.isFoodForMenu) {
        item = _itemsTemp.lastWhere((element) => (element.id == food.id && element.idMenu == food.idMenu));
      } else {
        item = _itemsTemp.lastWhere((element) => element.id == food.id);
      }
    } else {
      item = _itemsTemp.lastWhere((element) => element.id == food.id);
    }

    _itemsTemp.remove(item);
    if (_itemsTemp.length == 0) currentOrigin = null;
    notifyListeners();
  }

  dynamic getLastFood(String id) {
    dynamic item = _itemsTemp.lastWhere((element) => element.id == id);
    return item;
  }

  void removeAllFood(dynamic food) {
    _items.removeWhere((element) => element.id == food.id);
    notifyListeners();
  }

  void removeItemAtPosition(int position) {
    _items.removeAt(position);
    if (_items.length == 0) currentOrigin = null;
    notifyListeners();
  }

  void removeAllFoodTemp(dynamic food) {
    _items.removeWhere((element) => element.idNewFood == food.idNewFood);
    notifyListeners();
  }

  int getCount(dynamic food) {
    int count = 0;
    _items.forEach((key) {
      if (key.id == food.id) count++;
    });
    return count;
  }

  dynamic getFood(dynamic food) {
    var f;
    _items.forEach((key) {
      if (key.id == food.id) {
        f = key;
        return;
      }
    });
    return f;
  }

  int getFoodCount(dynamic food) {
    int count = 0;
    _items.forEach((key) {
      if (key.id == food.id) {
        count += key.quantity;
      }
    });
    return count;
  }

  void clear() {
    _items.clear();
    _currentOrigin = null;
    _options.clear();
    comment = "";
    _foodMenuSelected.clear();
    withPrice = true;
    notifyListeners();
  }

  void addOption(dynamic item, List<Option> options, {String key}) {
    item.optionSelected = options;
  }

  void removeOption(dynamic item) {
    _options[item.id].removeLast();
  }

  void refresh() {
    notifyListeners();
  }

  bool hasOptionSelectioned(Food food) {
    if (food == null) return false;
    bool hasOption = true;
    if (food.options.isEmpty) return true;
    if (food.optionSelected == null || food.optionSelected.isEmpty) return false;

    for (Option option in food.optionSelected) {
      if (option.itemOptionSelected.isEmpty) {
        hasOption = false;
      }
    }
    return hasOption;
  }

  int getFoodCountByIdNew(dynamic food) {
    int count = _itemsTemp.where((element) => element.idNewFood == food.idNewFood).toList().length;
    return count;
  }

  int get totalItems {
    int total = 0;
    items.forEach((element) {
      total += element.quantity;
    });
    return total;
  }
}
