import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/pages/splash.dart';
import 'package:menu_advisor/src/providers/AuthContext.dart';
import 'package:menu_advisor/src/providers/BagContext.dart';
import 'package:menu_advisor/src/providers/DataContext.dart';
import 'package:menu_advisor/src/providers/SettingContext.dart';
import 'package:menu_advisor/src/theme.dart';
import 'package:menu_advisor/src/types.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:provider/provider.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool loading = true;
  bool geolocationNotAllowed = false;
  Location location;

  @override
  void initState() {
    super.initState();

    checkPermission().then((permission) async {
      if (permission == LocationPermission.deniedForever) {
        geolocationNotAllowed = true;
      } else if (permission == LocationPermission.denied) {
        await requestPermission();
      }
      var position = await getCurrentPosition();
      setState(() {
        location = Location(
          type: 'Point',
          coordinates: [position.longitude, position.latitude],
        );
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(CRIMSON),
                ),
              ),
            ),
          )
        : geolocationNotAllowed
            ? MaterialApp(
                home: Scaffold(
                  body: Center(
                    child: Text(
                      "The app doesn't have acces to the geolocation device",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              )
            : MultiProvider(
                providers: [
                  ChangeNotifierProvider(
                    create: (_) => AuthContext(),
                  ),
                  ChangeNotifierProvider(
                    create: (_) => BagContext(),
                  ),
                  ChangeNotifierProvider(
                    create: (_) => SettingContext(),
                    lazy: false,
                  ),
                  ChangeNotifierProvider(
                    create: (_) => DataContext(
                      'fr',
                      location,
                    ),
                  )
                ],
                child: Consumer<SettingContext>(
                  builder: (_, settingContext, __) => MaterialApp(
                    title: 'Menu Advisor',
                    theme: theme,
                    debugShowCheckedModeBanner: false,
                    localizationsDelegates: [
                      AppLocalizations.delegate,
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                    locale: Locale(settingContext.languageCode),
                    localeResolutionCallback: (locale, supportedLocales) {
                      if (settingContext.languageCode != null)
                        return Locale(settingContext.languageCode);

                      for (var supportedLocale in supportedLocales) {
                        if (supportedLocale.languageCode ==
                                locale.languageCode &&
                            supportedLocale.countryCode == locale.countryCode) {
                          return supportedLocale;
                        }
                      }

                      return supportedLocales.first;
                    },
                    supportedLocales: [
                      const Locale('en', 'US'),
                      const Locale('fr', 'FR'),
                    ],
                    home: Splash(),
                  ),
                ),
              );
  }
}
