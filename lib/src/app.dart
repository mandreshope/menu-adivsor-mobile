import 'package:firebase_mlkit_language/firebase_mlkit_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:menu_advisor/src/pages/splash.dart';
import 'package:menu_advisor/src/providers/AuthContext.dart';
import 'package:menu_advisor/src/providers/BagContext.dart';
import 'package:menu_advisor/src/providers/CommandContext.dart';
import 'package:menu_advisor/src/providers/DataContext.dart';
import 'package:menu_advisor/src/providers/HistoryContext.dart';
import 'package:menu_advisor/src/providers/MenuContext.dart';
import 'package:menu_advisor/src/providers/OptionContext.dart';
import 'package:menu_advisor/src/providers/RestaurantContext.dart';
import 'package:menu_advisor/src/providers/SettingContext.dart';
import 'package:menu_advisor/src/theme.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_wrapper.dart';
import 'package:responsive_framework/utils/scroll_behavior.dart';

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
          create: (_) => CartContext(),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingContext(),
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (_) => DataContext(),
        ),
        ChangeNotifierProvider(
          create: (_) => CommandContext(),
        ),
        ChangeNotifierProvider(
          create: (_) => MenuContext(),
        ),
        ChangeNotifierProvider(
          create: (_) => OptionContext(),
        ),
        ChangeNotifierProvider(
          create: (_) => RestaurantContext(),
        ),
        ChangeNotifierProvider(
          create: (_) => HistoryContext(),
        )
      ],
      child: Consumer<SettingContext>(
        builder: (_, settingContext, __) => MaterialApp(
          title: 'Menu Advisor',
          theme: theme,
          debugShowCheckedModeBanner: true,
          localizationsDelegates: [
            // AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          locale: Locale(settingContext.languageCode),
          localeResolutionCallback: (locale, supportedLocales) {
            if (settingContext.languageCode != null) return Locale(settingContext.languageCode);

            for (var supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale.languageCode && supportedLocale.countryCode == locale.countryCode) {
                return supportedLocale;
              }
            }

            return supportedLocales.first;
          },
          supportedLocales: [
            const Locale('fr', 'FR'),
            const Locale('en', 'US'),
            const Locale('th', 'TH'),
          ],
          // home: Splash(),
          routes: route(),
          builder: (context, widget) => ResponsiveWrapper.builder(
          BouncingScrollWrapper.builder(context, widget),
          maxWidth: 1200,
          minWidth: 480,
          defaultScale: true,
          breakpoints: [
            ResponsiveBreakpoint.resize(480, name: MOBILE),
            // ResponsiveBreakpoint.autoScale(800, name: TABLET),
            ResponsiveBreakpoint.resize(1000, name: DESKTOP),
          ],
          background: Container(color: Color(0xFFF5F5F5))),
        ),
      ),
    );
  }
}
Map<String, WidgetBuilder> route() => {
        "/": (context) => Splash(),
};