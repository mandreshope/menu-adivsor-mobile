import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:menu_advisor/src/app.dart';

Future main() async {
  runApp(MyApp());
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}
