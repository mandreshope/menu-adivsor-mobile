import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:menu_advisor/src/animations/FadeAnimation.dart';
import 'package:menu_advisor/src/components/logo.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/pages/home.dart';
import 'package:menu_advisor/src/pages/login.dart';
import 'package:menu_advisor/src/providers/AuthContext.dart';
import 'package:menu_advisor/src/routes/routes.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Splash extends StatefulWidget {
  final Color textColor;

  const Splash({Key key, this.textColor}) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  double _opacity = 0;
  bool loadingUser = false;

  @override
  void initState() {
    super.initState();

    Timer(
        Duration(
          seconds: 2,
        ), () {
      setState(() {
        _opacity = 1;
      });
    });

    Timer(
      Duration(
        seconds: 4,
      ),
      () async {
        final AuthContext authContext = Provider.of<AuthContext>(
          context,
          listen: false,
        );

        // Loading user
        setState(() {
          loadingUser = true;
        });
        authContext.initialized.then((value) {
          _autoLogin(authContext);
        }).catchError((onError){
          _autoLogin(authContext);
        });

        /*try {
          await authContext.initialized;
        } catch (error) {
          Fluttertoast.showToast(
            msg: AppLocalizations.of(context).translate('session_expired'),
          );
          await authContext.logout();

          RouteUtil.goTo(
            context: context,
            child: LoginPage(),
            routeName: loginRoute,
            method: RoutingMethod.atTop,
          );
        }
        setState(() {
          loadingUser = false;
        });

        if (authContext.currentUser != null)
          RouteUtil.goTo(
            routeName: homeRoute,
            context: context,
            method: RoutingMethod.replaceLast,
            child: HomePage(),
          );
        else
          RouteUtil.goTo(
            context: context,
            child: LoginPage(),
            routeName: loginRoute,
            method: RoutingMethod.replaceLast,
          );*/
      },
    );
  }

  _autoLogin(AuthContext authContext) async {
    try {
      final result = await authContext.autoLogin();
      if (result) {
        RouteUtil.goTo(
          context: context,
          child: HomePage(),
          routeName: homeRoute,
        );
      } else {
        RouteUtil.goTo(
          context: context,
          child: LoginPage(),
          routeName: loginRoute,
          method: RoutingMethod.replaceLast,
        );
      }
    } catch (error) {
      print(error);

      RouteUtil.goTo(
        context: context,
        child: LoginPage(),
        routeName: loginRoute,
        method: RoutingMethod.replaceLast,
      );
    } finally {
      setState(() {
        loadingUser = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Color.alphaBlend(
                    Colors.white24,
                    Theme.of(context).primaryColor,
                  ),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [
                  0,
                  0.9,
                ],
              ),
            ),
            child: Center(
              child: FadeAnimation(
                0.8,
                MenuAdvisorTextLogo(
                  fontSize: 60,
                ),
              ),
            ),
          ),
          AnimatedOpacity(
            opacity: _opacity,
            duration: Duration(milliseconds: 200),
            child: Container(
              width: double.infinity,
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MenuAdvisorLogo(
                    size: 2 * MediaQuery.of(context).size.width / 5,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  AnimatedOpacity(
                    opacity: loadingUser ? 1 : 0,
                    duration: Duration(milliseconds: 200),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(CRIMSON),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
