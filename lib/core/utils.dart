import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

double remToPx(double rem) => rem * 20;

abstract class Palette {
  static const indigo = MaterialColor(0xFF6366F1, {
    50: Color(0xFFEEF2FF),
    100: Color(0xFFE0E7FF),
    200: Color(0xFFC7D2FE),
    300: Color(0xFFA5B4FC),
    400: Color(0xFF818CF8),
    500: Color(0xFF6366F1),
    600: Color(0xFF4F46E5),
    700: Color(0xFF4338CA),
    800: Color(0xFF3730A3),
    900: Color(0xFF312E81)
  });

  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Palette.indigo,
    fontFamily: 'Poppins',
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Palette.indigo,
    colorScheme: ColorScheme.dark(
        primary: Palette.indigo[500]!, secondary: Palette.indigo[400]!),
    fontFamily: 'Poppins',
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}
