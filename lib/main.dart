import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:menu_advisor/src/app.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(MyApp());
}
