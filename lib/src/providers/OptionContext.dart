import 'package:flutter/cupertino.dart';

class OptionContext with ChangeNotifier {

  refresh(){
    notifyListeners();
  }

}