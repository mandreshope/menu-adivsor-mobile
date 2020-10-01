import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:menu_advisor/src/pages/splash.dart';
import 'package:menu_advisor/src/providers/AuthContext.dart';
import 'package:menu_advisor/src/providers/BagContext.dart';
import 'package:menu_advisor/src/providers/DataContext.dart';
import 'package:menu_advisor/src/providers/SettingContext.dart';
import 'package:menu_advisor/src/theme.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:provider/provider.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthContext(),
        ),
        ChangeNotifierProvider(
          create: (_) => BagContext(),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingContext(),
        ),
        ChangeNotifierProvider(
          create: (_) => DataContext(),
        )
      ],
      child: MaterialApp(
        title: 'Menu Advisor',
        theme: theme,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode &&
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
    );
  }
}
