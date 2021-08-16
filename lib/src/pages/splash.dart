import 'dart:async';

import 'package:flutter/material.dart';
import 'package:menu_advisor/src/animations/FadeAnimation.dart';
import 'package:menu_advisor/src/components/logo.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/pages/home.dart';
import 'package:menu_advisor/src/pages/login.dart';
import 'package:menu_advisor/src/providers/AuthContext.dart';
import 'package:menu_advisor/src/providers/SettingContext.dart';
import 'package:menu_advisor/src/routes/routes.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:menu_advisor/src/utils/textTranslator.dart';
import 'package:provider/provider.dart';

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
        _init();
      },
    );
  }

  _init() async {
    final AuthContext authContext = Provider.of<AuthContext>(
      context,
      listen: false,
    );

    final SettingContext settingContext = Provider.of<SettingContext>(context, listen: false);

    // Loading user
    setState(() {
      loadingUser = true;
    });

    await settingContext.downloadLanguage();

    authContext.initialized.then((value) {
      _autoLogin(authContext);
    }).catchError((onError) {
      _autoLogin(authContext);
    });
  }

  _autoLogin(AuthContext authContext) async {
    try {
      final result = await authContext.autoLogin();
      if (result) {
        RouteUtil.goTo(
          context: context,
          child: HomePage(),
          routeName: homeRoute,
          method: RoutingMethod.replaceLast,
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(CRIMSON),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Consumer<SettingContext>(builder: (context, snapshot, w) {
                          return TextTranslator(
                            "Chargement... ",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                            ),
                          );
                        })
                      ],
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
