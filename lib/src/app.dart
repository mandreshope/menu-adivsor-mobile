import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/pages/splash.dart';
import 'package:menu_advisor/src/providers/AuthContext.dart';
import 'package:menu_advisor/src/providers/RouteContext.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:provider/provider.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool backButtonPressed = false;

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
      ],
      child: WillPopScope(
        onWillPop: () async {
          RouteContext routeContext =
          Provider.of<RouteContext>(context, listen: false);

          print(routeContext.canPop());
          return false;
          if (!backButtonPressed && !routeContext.canPop()) {
            backButtonPressed = true;
            Fluttertoast.showToast(msg: "Appuyez encore pour quitter");
            Future.delayed(Duration(milliseconds: 600), () {
              backButtonPressed = false;
            });
            return false;
          } else
            routeContext.pop();
          return true;
        },
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
                  color: TITLE_COLOR,
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
      ),
    );
  }
}
