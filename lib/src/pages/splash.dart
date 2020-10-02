import 'dart:async';

import 'package:flutter/material.dart';
import 'package:menu_advisor/src/animations/FadeAnimation.dart';
import 'package:menu_advisor/src/components/logo.dart';
import 'package:menu_advisor/src/pages/home.dart';
import 'package:menu_advisor/src/pages/login.dart';
import 'package:menu_advisor/src/providers/AuthContext.dart';
import 'package:menu_advisor/src/routes/routes.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:provider/provider.dart';

class Splash extends StatefulWidget {
  final Color textColor;

  const Splash({Key key, this.textColor}) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  double _opacity = 0;

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
        final AuthContext authContext =
            Provider.of<AuthContext>(context, listen: false);

        await authContext.initialized;

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
          );
      },
    );
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
              color: Colors.white,
              child: Center(
                child: MenuAdvisorLogo(
                  size: 2 * MediaQuery.of(context).size.width / 5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
