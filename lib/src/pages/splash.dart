import 'dart:async';

import 'package:flutter/material.dart';
import 'package:menu_advisor/src/animations/FadeAnimation.dart';
import 'package:menu_advisor/src/components/logo.dart';
import 'package:menu_advisor/src/pages/getting_started.dart';
import 'package:menu_advisor/src/pages/home.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:page_transition/page_transition.dart';
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
        if (sharedPrefs.containsKey('gettingStartedAlreadyVisited') &&
            sharedPrefs.getBool('gettingStartedAlreadyVisited')) {
          RouteUtil.goTo(
            context: context,
            method: RouteMethod.replaceLast,
            transitionType: PageTransitionType.rightToLeftWithFade,
            child: HomePage(),
          );
          await (await SharedPreferences.getInstance()).setBool('gettingStartedAlreadyVisited', true);
        } else
          RouteUtil.goTo(
            context: context,
            method: RouteMethod.replaceLast,
            transitionType: PageTransitionType.rightToLeftWithFade,
            child: GettingStartedPage(),
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
