import 'package:flutter/material.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/pages/Splash.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Menu Advisor',
      theme: ThemeData(
        primaryColor: CRIMSON,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
