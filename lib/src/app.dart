import 'package:firebase_mlkit_language/firebase_mlkit_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:menu_advisor/src/pages/splash.dart';
import 'package:menu_advisor/src/providers/AuthContext.dart';
import 'package:menu_advisor/src/providers/BagContext.dart';
import 'package:menu_advisor/src/providers/CommandContext.dart';
import 'package:menu_advisor/src/providers/DataContext.dart';
import 'package:menu_advisor/src/providers/MenuContext.dart';
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
            const Locale('en', 'US'),
            const Locale('fr', 'FR'),

          ],
          home: Splash(),
        ),
      ),
    );
  }
}
