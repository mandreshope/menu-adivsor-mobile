import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/pages/splash.dart';
import 'package:menu_advisor/src/providers/AuthContext.dart';
import 'package:menu_advisor/src/providers/BagContext.dart';
import 'package:menu_advisor/src/providers/RouteContext.dart';
import 'package:menu_advisor/src/providers/SettingContext.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:provider/provider.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => RouteContext(),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthContext(),
        ),
        ChangeNotifierProvider(
          create: (_) => BagContext(),
        ),
        ChangeNotifierProvider(
          create: (context) => SettingContext(context),
        )
      ],
      child: MaterialApp(
        title: 'Menu Advisor',
        theme: ThemeData(
          primaryColor: CRIMSON,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          textTheme: GoogleFonts.ralewayTextTheme(textTheme).copyWith(
            headline5: GoogleFonts.raleway(
              textStyle: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: DARK_BLUE,
              ),
            ),
            caption: GoogleFonts.raleway(
              textStyle: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          scaffoldBackgroundColor: BACKGROUND_COLOR,
        ),
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
