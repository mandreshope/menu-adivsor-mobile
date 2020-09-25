import 'dart:async';

import 'package:flutter/material.dart';
import 'package:menu_advisor/src/animations/FadeAnimation.dart';
import 'package:menu_advisor/src/components/logo.dart';
import 'package:menu_advisor/src/pages/getting_started.dart';
import 'package:menu_advisor/src/pages/home.dart';
import 'package:menu_advisor/src/pages/login.dart';
import 'package:menu_advisor/src/providers/AuthContext.dart';
import 'package:menu_advisor/src/routes/routes.dart';
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
  @override
  void initState() {
    super.initState();

    Timer(
      Duration(
        seconds: 3,
      ),
      () async {
        final sharedPrefs = await SharedPreferences.getInstance();
        final authContext = Provider.of<AuthContext>(context, listen: false);

        if (!sharedPrefs.containsKey('gettingStartedAlreadyVisited') ||
            !sharedPrefs.getBool('gettingStartedAlreadyVisited')) {
          await (await SharedPreferences.getInstance())
              .setBool('gettingStartedAlreadyVisited', true);
          RouteUtil.goTo(
            routeName: gettingStartedRoute,
            context: context,
            method: RoutingMethod.replaceLast,
            child: GettingStartedPage(),
          );
        } else if (authContext.currentUser != null)
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
          );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
    );
  }
}
