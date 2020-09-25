import 'package:flutter/material.dart';
import 'package:menu_advisor/src/providers/RouteContext.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

enum RouteMethod {
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
    RouteMethod method = RouteMethod.initial,
    RoutingMethod method = RoutingMethod.initial,
  }) {
    final RouteContext routeContext =
        Provider.of<RouteContext>(context, listen: false);
    if (routeContext.currentRoute == routeName) return false;

    switch (method) {
      case RouteMethod.initial:
      case RoutingMethod.initial:
        routeContext.push(routeName);
        Navigator.of(context).push(
          PageTransition(
            duration: Duration(milliseconds: 500),
            child: child,
            type: transitionType,
          ),
        );
        return true;

      case RouteMethod.replaceLast:
      case RoutingMethod.replaceLast:
        routeContext.pushAndReplace(routeName);
        Navigator.of(context).pushReplacement(
          PageTransition(
            duration: Duration(milliseconds: 500),
            child: child,
            type: transitionType,
          ),
        );
        return true;

      case RouteMethod.atTop:
      case RoutingMethod.atTop:
        routeContext.pushAtTop(routeName);
        Navigator.of(context).pushAndRemoveUntil(
          PageTransition(
            duration: Duration(milliseconds: 500),
            child: child,
            type: transitionType,
          ),
          (route) => false,
        );
        return true;

      default:
        return false;
    }
  }
}
