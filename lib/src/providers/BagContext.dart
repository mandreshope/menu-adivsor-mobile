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
      // _items[item] = number;
      _items.update(
        item,
        (value) => number,
        ifAbsent: () => number,
      );
      currentOrigin = item.isFoodForMenu ? item.restaurant['_id'] : item.restaurant;
      notifyListeners();
      return true;
    }

    return false;
  }

  bool removeFoodItemMenu(String idFood,String idOption){
    _items.forEach((food, count) {
      if(food.isFoodForMenu){
        food.optionSelected.forEach((f){
          if (f.sId == idOption)
            f.itemOptionSelected.clear();
        });
      }
    });
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
      if (food.price != null && food.price.amount != null) totalPrice += food.price.amount / 100* count;
      if (food.isMenu){
        
      }else{
        food.options?.forEach((option){
        option.itemOptionSelected?.forEach((itemOption) {
        if(itemOption.price != null) totalPrice += itemOption.price/100;
      });
      });

      }
      
      
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
    _items.removeWhere((key, _) { 
      if(key.id == food.id){
        if (food.isMenu){

        }else{
          key.optionSelected?.forEach((itemOption) {
          itemOption.itemOptionSelected?.clear();
        
          });
        }
         return true;
      } 
      return false;
    });
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

  double getTotalPriceFood(dynamic food){
    double totalPrice = 0;
    int count = getCount(food);
// return 15.2;
    _items.forEach((key, value) {
      
      if (key.id == food.id) {
        key.optionSelected?.forEach((itemOption) {
          itemOption.itemOptionSelected?.forEach((item){
            if(item.price != null) totalPrice += (item.price.toDouble()/100);
          });
        
      });
      }
    });

    totalPrice += (food.price?.amount == null ? 00 : food.price.amount / 100)*count;

    return (totalPrice);
    
  }

  
  Food getFood(dynamic food) {
    var f;
    _items.forEach((key, value) {
      if (key.id == food.id) {
        f = key;
        return; 
      }
    });
    return f;
  }

  void clear() {
    _items.clear();
    _currentOrigin = null;
    notifyListeners();
  }
}
