import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:menu_advisor/src/providers/RouteContext.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

enum RoutingMethod {
  initial,
  replaceLast,
  atTop,
}

class RouteUtil {
  static bool _isBackButtonPressedInTimeLapse = false;

  static bool goTo({
    @required BuildContext context,
    @required Widget child,
    @required String routeName,
    PageTransitionType transitionType = PageTransitionType.fade,
    RoutingMethod method = RoutingMethod.initial,
  }) {
    final RouteContext routeContext =
        Provider.of<RouteContext>(context, listen: false);
    if (routeContext.currentRoute == routeName) return false;

    switch (method) {
      case RoutingMethod.initial:
        routeContext.push(routeName);
        Navigator.of(context).push(
          PageTransition(
            duration: Duration(milliseconds: 500),
            child: WillPopScope(
              onWillPop: () => _onWillPop(context),
              child: child,
            ),
            type: transitionType,
          ),
        );
        return true;

      case RoutingMethod.replaceLast:
        routeContext.pushAndReplace(routeName);
        Navigator.of(context).pushReplacement(
          PageTransition(
            duration: Duration(milliseconds: 500),
            child: WillPopScope(
              onWillPop: () => _onWillPop(context),
              child: child,
            ),
            type: transitionType,
          ),
        );
        return true;

      case RoutingMethod.atTop:
        routeContext.pushAtTop(routeName);
        Navigator.of(context).pushAndRemoveUntil(
          PageTransition(
            duration: Duration(milliseconds: 500),
            child: WillPopScope(
              onWillPop: () => _onWillPop(context),
              child: child,
            ),
            type: transitionType,
          ),
          (route) => false,
        );
        return true;

      default:
        return false;
    }
  }

  static void goBack({
    @required BuildContext context,
  }) {
    Navigator.of(context).pop();
    Provider.of<RouteContext>(context, listen: false).pop();
  }

  static Future<bool> _onWillPop(BuildContext context) async {
    final RouteContext routeContext =
        Provider.of<RouteContext>(context, listen: false);

    if (!_isBackButtonPressedInTimeLapse && !routeContext.canPop()) {
      _isBackButtonPressedInTimeLapse = true;
      Fluttertoast.showToast(
        msg: AppLocalizations.of(context).translate("before_exit_message"),
      );
      Future.delayed(
        Duration(seconds: 1),
        () {
          _isBackButtonPressedInTimeLapse = false;
        },
      );
      return false;
    }

    routeContext.pop();
    return true;
  }
}
