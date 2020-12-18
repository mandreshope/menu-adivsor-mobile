import 'package:flutter/foundation.dart';
import 'package:menu_advisor/src/utils/extensions.dart';

import '../models.dart';

class MenuContext extends ChangeNotifier {
  Menu menu;
  Map<String, List<Food>> _foodsGrouped;

  List<Food> _selectedFood = List();
  Map<String, List<Food>> selectedMenu = Map();

  set foodsGrouped(List<Food> foods) => _foodsGrouped = foods.groupBy((f) {
        // f.isMenu = true;
        return f.type.name["fr"];
      });

  get foodsGrouped => _foodsGrouped;

  select(String entry, food) {
    
    selectedMenu[entry] = [food];

    if (_foodsGrouped.length == selectedMenu.length) {

      _selectedFood.clear();
      for (var entry in selectedMenu.entries){
        _selectedFood.addAll(entry.value);
      }

    }else{
      
    }

    notifyListeners();

  }

}
