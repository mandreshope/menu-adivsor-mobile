import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:menu_advisor/src/app.dart';
import 'package:menu_advisor/src/services/firebase_config.dart';
import 'package:menu_advisor/src/services/http_overrides.dart';
import 'package:menu_advisor/src/services/notification_service.dart';
import 'package:menu_advisor/src/services/stripe.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:permission_handler/permission_handler.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseConfig.platformOptions,
    );
  } on FirebaseException catch (e) {
    if (e.code == 'duplicate-app') {
      // you can choose not to do anything here or either
      // In a case where you are assigning the initializer instance to a FirebaseApp variable, // do something like this:
      //
      //   app = Firebase.app('SecondaryApp');
      //
    } else {
      throw e;
    }
  } catch (e) {
    rethrow;
  }

  await initNotification(); //init firebase_messaging && local_notification

  await AppLocalizations.instance.load();

  await [
    Permission.storage,
    Permission.location,
    Permission.locationAlways,
    Permission.locationWhenInUse,
    Permission.camera,
    Permission.appTrackingTransparency,
  ].request();

  HttpOverrides.global = MyHttpOverrides();

  ///flutter_stripe config
  await StripeService.init();
  //

  runApp(MyApp());
}
