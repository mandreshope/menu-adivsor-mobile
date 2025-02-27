import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:menu_advisor/src/constants/colors.dart';

final ThemeData theme = ThemeData(
  primaryColor: CRIMSON,
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: CRIMSON,
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: CRIMSON,
  ),
  visualDensity: VisualDensity.adaptivePlatformDensity,
  textTheme: GoogleFonts.ralewayTextTheme().copyWith(
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
  appBarTheme: AppBarTheme(
    centerTitle: true,
    backgroundColor: CRIMSON,
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    errorStyle: TextStyle(
      fontSize: 14,
    ),
  ),
  scaffoldBackgroundColor: BACKGROUND_COLOR,
);
