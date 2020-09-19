import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

enum RouteMethod {
  initial,
  replaceLast,
  atTop,
}

class RouteUtil {
  static goTo(
      {@required BuildContext context,
      @required Widget child,
      PageTransitionType transitionType = PageTransitionType.fade,
      RouteMethod method = RouteMethod.initial}) {
    switch (method) {
      case RouteMethod.initial:
        Navigator.of(context).push(
          PageTransition(
            duration: Duration(milliseconds: 500),
            child: child,
            type: transitionType,
          ),
        );
        break;

      case RouteMethod.replaceLast:
        Navigator.of(context).pushReplacement(
          PageTransition(
            duration: Duration(milliseconds: 500),
            child: child,
            type: transitionType,
          ),
        );
        break;

      case RouteMethod.atTop:
        Navigator.of(context).pushAndRemoveUntil(
          PageTransition(
            duration: Duration(milliseconds: 500),
            child: child,
            type: transitionType,
          ),
          (route) => false,
        );
        break;

      default:
    }
  }
}
