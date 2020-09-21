import 'package:flutter/material.dart';
import 'package:menu_advisor/src/routes/routes.dart';

class RouteContext extends ChangeNotifier {
  List<String> stack = [splashRoute];

  void push(String routeName) {
    stack.add(routeName);
  }

  void pushAndReplace(String routeName) {
    stack.removeLast();
    stack.add(routeName);
  }

  void pushAtTop(String routeName) {
    stack.clear();
    stack.add(routeName);
  }

  void pop() {
    if (stack.length > 1)
      stack.removeLast();
  }

  bool canPop() => stack.length > 1;

  String get currentRoute => stack.last;
}
