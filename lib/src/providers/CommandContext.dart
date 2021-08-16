import 'package:flutter/material.dart';
import 'package:menu_advisor/src/models.dart';

class CommandContext extends ChangeNotifier {
  PaymentCard _paymentCard;
  String _commandType;
  String _deliveryAddress;
  DateTime _deliveryDate;
  TimeOfDay _deliveryTime;
  List<Food> _items;

  set paymentCard(PaymentCard paymentCard) {
    _paymentCard = paymentCard;
    notifyListeners();
  }

  PaymentCard get paymentCard => _paymentCard;

  set commandType(String commandType) {
    _commandType = commandType;
    notifyListeners();
  }

  String get commandType => _commandType;

  set deliveryAddress(String deliveryAddress) {
    _deliveryAddress = deliveryAddress;
    notifyListeners();
  }

  String get deliveryAddress => _deliveryAddress;

  set deliveryDate(DateTime deliveryDate) {
    _deliveryDate = deliveryDate;
    notifyListeners();
  }

  DateTime get deliveryDate => _deliveryDate;

  set deliveryTime(TimeOfDay deliveryTime) {
    _deliveryTime = deliveryTime;
    notifyListeners();
  }

  TimeOfDay get deliveryTime => _deliveryTime;

  set items(List<Food> items) {
    _items = items;
    notifyListeners();
  }

  List<Food> get items => _items;

  clear() {
    _paymentCard = null;
    _commandType = null;
    _deliveryAddress = null;
    _deliveryDate = null;
    _deliveryTime = null;
    _items = null;
    notifyListeners();
  }
}
