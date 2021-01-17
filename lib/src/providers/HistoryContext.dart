import 'package:flutter/material.dart';

class HistoryContext with ChangeNotifier {

  Map<String, bool> commandByTypeValue = Map();

  setCollapse(String key,bool value) {
    commandByTypeValue[key] = value;
    notifyListeners();
  }

}