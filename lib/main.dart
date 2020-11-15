import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:menu_advisor/src/app.dart';
import 'package:permission_handler/permission_handler.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await [
    Permission.storage,Permission.location
  ].request();

  runApp(MyApp());
}
