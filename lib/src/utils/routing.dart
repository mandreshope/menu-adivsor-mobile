import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

enum RoutingMethod {
  initial,
  replaceLast,
  atTop,
}

class RouteUtil {
  static bool goTo({
    @required BuildContext context,
    @required Widget child,
    @required String routeName,
    PageTransitionType transitionType = PageTransitionType.fade,
    RoutingMethod method = RoutingMethod.initial,
    Object arguments,
  }) {
    switch (method) {
      case RoutingMethod.initial:
        Navigator.of(context).push(
          PageTransition(
            duration: Duration(milliseconds: 500),
            settings: RouteSettings(
              name: routeName,
              arguments: arguments,
            ),
            child: child,
            type: transitionType,
          ),
        );
        print("go to : /" + child.toString());
        return true;

      case RoutingMethod.replaceLast:
        Navigator.of(context).pushReplacement(
          PageTransition(
            duration: Duration(milliseconds: 500),
            settings: RouteSettings(
              name: routeName,
              arguments: arguments,
            ),
            child: child,
            type: transitionType,
          ),
        );
        print("go to : /" + child.toString());
        return true;

      case RoutingMethod.atTop:
        Navigator.of(context).pushAndRemoveUntil(
          PageTransition(
            duration: Duration(milliseconds: 500),
            settings: RouteSettings(
              name: routeName,
              arguments: arguments,
            ),
            child: child,
            type: transitionType,
          ),
          (route) => false,
        );
        print("go to : /" + child.toString());
        return true;

      default:
        return false;
    }
  }

  static void goToAndRemoveUntil<T extends Object>({
    @required BuildContext context,
    @required Widget child,
    @required String routeName,
    @required bool Function(Route<T>) predicate,
    PageTransitionType transitionType = PageTransitionType.fade,
    Object arguments,
  }) {
    Navigator.of(context).pushAndRemoveUntil<T>(
      PageTransition(
        duration: Duration(milliseconds: 500),
        settings: RouteSettings(
          name: routeName,
          arguments: arguments,
        ),
        child: child,
        type: transitionType,
      ),
      predicate,
    );
    print("go to : /" + child.toString());
  }

  static void goBack({
    @required BuildContext context,
  }) {
    Navigator.of(context).pop();
    print("go back");
  }
}
