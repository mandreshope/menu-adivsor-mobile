import 'package:flutter/foundation.dart';
import 'package:menu_advisor/src/providers/BagContext.dart';

import '../models/models.dart';

class MenuContext extends ChangeNotifier {
  List<Food> _selectedFood = [];
  Map<String, List<Food>> selectedMenu = Map();

  select(CartContext cartContext, Menu menu, String entry, food) {
    if (selectedMenu[entry] != null && selectedMenu[entry].firstWhere((element) => element.id != food.id, orElse: () => null) != null) {
      cartContext.foodMenuSelected[entry].optionSelected = [];
      selectedMenu[entry] = [food];
      cartContext.addOption(menu, cartContext.foodMenuSelected[entry].optionSelected);
      cartContext.refresh();
    } else
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

  clear() {
    selectedMenu.clear();
    _selectedFood.clear();
  }
}
