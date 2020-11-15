import 'package:flutter/foundation.dart';
import 'package:menu_advisor/src/utils/extensions.dart';

import '../models.dart';

class MenuContext extends ChangeNotifier {
  Menu menu;
  Map<String, List<Food>> _foodsGrouped;

  set foodsGrouped(List<Food> foods) => _foodsGrouped = foods.groupBy((f) {
        // f.isMenu = true;
        return f.type.tag;
      });

  get foodsGrouped => _foodsGrouped;
}
