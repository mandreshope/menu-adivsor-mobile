import 'package:flutter/cupertino.dart';
import 'package:menu_advisor/src/models/models.dart';

class OptionContext with ChangeNotifier {
  List<ItemsOption> itemOptions = [];

  refresh() {
    notifyListeners();
  }

  int get quantityOptions {
    int val = 0;
    for (ItemsOption itemsOption in itemOptions) {
      val += itemsOption.quantity;
    }
    return val;
  }
}
