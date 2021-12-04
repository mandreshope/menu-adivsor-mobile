import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:menu_advisor/src/models/models.dart';
import 'package:menu_advisor/src/models/restaurants/restaurant_plage_discount_model.dart';

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

  bool hasSameOriginAsInBag(dynamic item) =>
      currentOrigin == null ||
      ((item.restaurant is String)
              ? item.restaurant
              : item.restaurant['_id']) ==
          currentOrigin;

  bool hasSamePricingAsInBag(dynamic item) => !withPrice
      ? true
      : (pricelessItems && (item.price == null || item.price.amount == null)) ||
          (!pricelessItems && item.price != null && item.price.amount != null);

  bool addItem(dynamic item, number, bool isAdd) {
    if (itemCount == 0 ||
        (hasSamePricingAsInBag(item) && hasSameOriginAsInBag(item))) {
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
    List<Option> _temp = _options.values
        .expand((element) => element)
        .toList()
        .expand((element) => element)
        .toList();
    _temp.forEach((option) {
      option.itemOptionSelected?.forEach((itemOption) {
        if (itemOption.price != null && itemOption.price.amount != null)
          totalPrice += itemOption.price.amount / 100 * itemOption.quantity;
      });
    });

    return totalPrice;
  }

  double remiseInEuro({
    @required bool discountIsPrice,
    @required double discountValue,
    @required double totalPrice,
  }) {
    if (discountIsPrice) {
      ///in €
      return discountValue;
    } else {
      ///remiseInEuro = totalPrice(€) - discountValue% (ex: 10000€-10% = 1000€)
      final remiseInEuro = ((totalPrice * discountValue) / 100);
      return remiseInEuro;
    }
  }

  int calculTotalDiscount(
      {int totalPriceSansRemise, int remiseWithCodeDiscount}) {
    final dif = (totalPriceSansRemise - remiseWithCodeDiscount);
    final totalDiscount = dif.isNegative ? 0 : dif;
    return totalDiscount;
  }

  double discountValueInPlageDiscount({
    @required double totalPriceSansRemise,
    @required bool discountIsPrice,
    @required double discountValue,
    @required List<PlageDiscount> plageDiscount,
  }) {
    ///check discountIsPrice
    ///if discountIsPrice is false, we apply the plageDiscount
    double result;
    if (discountIsPrice == true) {
      result = discountValue;
    } else {
      final plages = plageDiscount.where((plage) =>
          (int.tryParse(plage.max) ?? 0) >= (totalPriceSansRemise / 100) &&
          (int.tryParse(plage.min) ?? 0) <= (totalPriceSansRemise / 100));
      if (plages.isNotEmpty) {
        result = double.tryParse(plages.first.value) ?? 0.0;
      }
    }
    return result ?? 0.0;
  }

  //in Euro
  double priceOrPourcent({
    @required double totalPrice,
    @required bool discountIsPrice,
    @required double discountValue,
  }) {
    double total = 0.0;
    if (discountIsPrice) {
      ///total(€) = totalPrice(€) - discountValue(€) (ex: 10000€-10€ = 9990€)
      total = totalPrice - discountValue;
    } else {
      ///remiseInEuro = totalPrice(€) - discountValue% (ex: 10000€-10% = 1000€)
      ///total(€) = totalPrice(€) - remiseInEuro (ex: 10 000€ - 1 000€ = 9 000€)
      final remiseInEuro = ((totalPrice * discountValue) / 100);
      total = (totalPrice - remiseInEuro);
    }
    if (total.isNegative) {
      total = 0.0;
    }
    return double.parse(total.toStringAsFixed(2));
  }

  double calculremise({
    @required double totalPrice,
    @required bool discountIsPrice,
    @required double discountValue,
  }) {
    if (discountIsPrice == null && discountValue == null) {
      return totalPrice;
    }
    return priceOrPourcent(
      totalPrice: totalPrice,
      discountIsPrice: discountIsPrice,
      discountValue: discountValue,
    );
  }

  bool contains(dynamic food) {
    if (food.isFoodForMenu)
      return _items.firstWhere(
            (element) =>
                (element.id == food.id && element.idMenu == food.idMenu),
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
            (element) =>
                (element.id == food.id && element.idMenu == food.idMenu),
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
        item = _itemsTemp.lastWhere((element) =>
            (element.id == food.id && element.idMenu == food.idMenu));
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

  bool hasMenuObligatorySelected(Menu menu, List<MenuFood> menuFoods) {
    bool hasMenuObligatorySelected = false;
    bool hasOptionSelected = false;
    final menuIds = menu.foodMenuSelected.keys.toList();
    if (menuIds.isEmpty) {
      return false;
    }
    List<bool> listMenu = [];
    List<bool> listOption = [];

    for (final menuFood in menuFoods) {
      menu.foodMenuSelected.forEach((menuId, value) {
        if (menuId == menuFood.sId) {
          if (menuFood.isObligatory && value.isNotEmpty) {
            listMenu.add(true);
          } else {
            listMenu.add(false);
          }
        }
        value.forEach((food) {
          if (hasOptionSelectioned(food)) {
            listOption.add(true);
          } else {
            listOption.add(false);
          }
        });
      });
    }

    hasMenuObligatorySelected = listMenu.where((e) => e).toList().isNotEmpty;
    if (listOption.contains(false)) {
      hasOptionSelected = false;
    } else {
      hasOptionSelected = true;
    }

    if (hasMenuObligatorySelected && hasOptionSelected) {
      return true;
    } else if (allMenuIsNotObligatory(menu, menuFoods) && hasOptionSelected) {
      return true;
    } else {
      return false;
    }
  }

  bool allMenuIsNotObligatory(Menu menu, List<MenuFood> menuFoods) {
    final menusObligatory = menuFoods.where((m) => m.isObligatory);
    return menusObligatory.isEmpty && menu.foodMenuSelecteds.isNotEmpty;
  }

  bool hasOptionSelectioned(Food food) {
    if (food == null) return false;
    bool hasOption = true;
    if (food.options.isEmpty) {
      return true;
    }
    if (food.optionSelected == null || food.optionSelected.isEmpty) {
      return false;
    }

    List<bool> checkList = [];
    final obligatoryList =
        food.optionSelected.where((option) => option.isObligatory).toList();
    final obligatoryCheckList = obligatoryList
        .map((option) =>
            option?.isObligatory == true &&
            option.itemOptionSelected.isNotEmpty)
        .toList();
    for (Option option in food.optionSelected) {
      if (option.itemOptionSelected.isEmpty) {
        checkList.add(false);
      } else if (food.options.length == 1) {
        checkList.add(true);
      } else {
        checkList.add(false);
      }
    }
    hasOption = checkList.where((e) => e).toList().isNotEmpty ||
        (!obligatoryCheckList.contains(false) &&
            obligatoryCheckList.isNotEmpty);
    return hasOption;
  }

  int get totalItems {
    int total = 0;
    items.forEach((element) {
      total += element.quantity;
    });
    return total;
  }
}
