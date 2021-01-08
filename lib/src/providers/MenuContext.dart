import 'package:flutter/foundation.dart';
import 'package:menu_advisor/src/providers/BagContext.dart';
import 'package:menu_advisor/src/utils/extensions.dart';

import '../models.dart';

class MenuContext extends ChangeNotifier {
  Menu menu;
  Map<String, List<Food>> _foodsGrouped;

  List<Food> _selectedFood = List();
  Map<String, List<Food>> selectedMenu = Map();

  set foodsGrouped(List<Food> foods) => _foodsGrouped = foods.groupBy((f) {
        // f.isMenu = true;
        return (f.type is String) ? f.type : f.type.name["fr"] ?? "";
      });

  get foodsGrouped => _foodsGrouped;

  select(CartContext cartContext, String entry, food) {
    
    if (selectedMenu[entry] != null && selectedMenu[entry].firstWhere((element) => element.id != food.id,orElse: ()=>null) != null){
      cartContext.foodMenuSelected[entry].optionSelected = List();
      selectedMenu[entry] = [food];
      cartContext.addOption(menu, cartContext.foodMenuSelected[entry].optionSelected);
      cartContext.refresh();
    }
    else
      selectedMenu[entry] = [food];
    /*if (_foodsGrouped.length == selectedMenu.length) {

      _selectedFood.clear();
      for (var entry in selectedMenu.entries){
        _selectedFood.addAll(entry.value);
      }

    }else{
      
    }*/

    notifyListeners();

  }

  clear(){
    selectedMenu.clear();
    _selectedFood.clear();
  }

}
