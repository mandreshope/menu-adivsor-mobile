import 'package:flutter/material.dart';
import 'package:menu_advisor/src/models.dart';

class BagContext extends ChangeNotifier {
  Map<Food, int> _items;
  int _itemCount = 0;

  bool addItem(Food item, number) {
    _itemCount++;
    return false;
  }

  Map<Food, int> get items => _items;

  int get itemCount => _itemCount;

  double get totalPrice {
    double totalPrice = 0;

    _items.forEach((food, count) {
      totalPrice += food.price * count;
    });

    return totalPrice;
  }
}
