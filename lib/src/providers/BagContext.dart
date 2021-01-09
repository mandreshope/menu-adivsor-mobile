import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:menu_advisor/src/models.dart';

class CartContext extends ChangeNotifier {
  Map<dynamic, int> _items = Map();
  Map<String, List<List<Option>>> _options = Map();
  String _currentOrigin;
  Queue q = Queue();
  String comment = "";
  bool withPrice = true;

  Map<String,Food> _foodMenuSelected = Map();

  // Food _foodMenuSelected;
  setFoodMenuSelected(String key, value) { 
    _foodMenuSelected[key] = value;
   _foodMenuSelected[key].isMenu = true;  
  }

  Map<String,Food> get foodMenuSelected => _foodMenuSelected;
  List<Food> get foodMenuSelecteds {
    List<Food> foods = List();
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
    return _items.keys.length > 0 &&
        _items.keys.any(
          (element) => element.price == null || element.price.amount == null,
        );
  }

  bool hasSameOriginAsInBag(dynamic item) => 
  currentOrigin == null || ((item.restaurant is String) ? item.restaurant : item.restaurant['_id']) == currentOrigin;

  bool hasSamePricingAsInBag(dynamic item) => 
  (pricelessItems && (item.price == null || item.price.amount == null)) || (!pricelessItems && item.price != null && item.price.amount != null);

  bool addItem(dynamic item, number,bool isAdd) {
    if (itemCount == 0 || (hasSamePricingAsInBag(item) && hasSameOriginAsInBag(item))) {
      // _items[item] = number;
      _items.update(
        item,
        (value) => number,
        ifAbsent: () => number,
      );
      if (item.optionSelected != null)
        isAdd ? addOption(item, item.optionSelected) : removeOption(item);
      currentOrigin = (item.restaurant is String) ? item.restaurant : item.restaurant['_id'] ;
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
  Map<dynamic, List<List<Option>>> get options => _options;

  int get itemCount => _items.length;

  double get totalPrice {
    double totalPrice = 0;

    _items.forEach((food, count) {
      /*if (food.isMenu) {
        food.foods.forEach((f){
         if (f.price != null && f.price.amount != null) totalPrice += f.price.amount / 100 * count;
        });
      }else*/
      if (food.isMenu){
        if (food.type == "per_food"){
          if (food.price != null && food.price.amount != null) totalPrice += food.price.amount / 100* count;
        }else if(food.type == "priceless"){

        }else if (food.type == "fixed_price"){
          if (food.price != null && food.price.amount != null) totalPrice += food.price.amount / 100* count;
        }
        
        
      }else{
          if (food.price != null && food.price.amount != null) totalPrice += food.price.amount / 100* count;
      }
      
      /*if (food.isMenu){
        if (per_food)
        priceless
        fixed_price
      }else{
        food.options?.forEach((option){
        option.itemOptionSelected?.forEach((itemOption) {
        if(itemOption.price != null) totalPrice += itemOption.price/100;
      });
      });

    }*/
      
      
    });
    
    List<Option> _temp = _options.values.expand((element) => element).toList().expand((element) => element).toList();
    _temp.forEach((option) {
      option.itemOptionSelected?.forEach((itemOption) {
        if(itemOption.price != null && itemOption.price.amount != null) totalPrice += itemOption.price.amount/100;
      });
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
        //if (food.isMenu){

        //}else{
          key.optionSelected?.forEach((itemOption) {
          itemOption.itemOptionSelected?.clear();
        
         });
      _options[key.id]?.clear();
       // }
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
    int count = _items[food];
// return 15.2;
    /*_items.forEach((key, value) {
      
      if (key.id == food.id) {
        key.optionSelected?.forEach((itemOption) {
          itemOption.itemOptionSelected?.forEach((item){
            if(item.price != null) totalPrice += (item.price.toDouble()/100);
          });
        
      if (per_food)
              priceless
              fixed_price

            });
            }
      });*/

      if (food.isMenu){
              if (food.type == "per_food"){

      if (food.price != null && food.price.amount != null) totalPrice += food.price.amount / 100* count;

              }else if(food.type == "priceless"){

              }else if (food.type == "fixed_price"){

      if (food.price != null && food.price.amount != null) totalPrice += food.price.amount / 100* count;

              }
        
        
      }else{

        if (food.price != null && food.price.amount != null) totalPrice += food.price.amount / 100*count;

      }

    List<List<Option>> _values = _options[food.id];
    if (_values != null){
      
    List<Option> _temp = _values.expand((element) => element).toList();
    _temp.forEach((option) {
      option.itemOptionSelected?.forEach((itemOption) {
        if(itemOption.price != null && itemOption.price.amount != null) totalPrice += itemOption.price.amount/100;
      });
    });
  }

    //totalPrice += (food.price?.amount == null ? 00 : food.price.amount / 100)*count;

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
    _options.clear();
    comment = "";
    _foodMenuSelected.clear();
    notifyListeners();
  }

  void addOption(dynamic item, List<Option> options,{String key}) {
    if (_options[item.id] == null) {
      _options[item.id] = List();
    }
    if (item.isMenu){
      if (_foodMenuSelected != null && key != null){
      _foodMenuSelected[key].optionSelected = options.map((e) => Option.copy(e)).toList();
      _options[item.id] = [options.map((e) => Option.copy(e)).toList()];
      }
    }else
      _options[item.id].add(options.map((e) => Option.copy(e)).toList());
  }

  void removeOption(dynamic item) {
    _options[item.id].removeLast();
  }

  void refresh(){
    notifyListeners();
  }


}
