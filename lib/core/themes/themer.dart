import 'package:flutter/material.dart';
import 'colors.dart';
import 'fonts.dart';

class Themer {
  static const String defaultFontFamily = Fonts.inter;

  static final ThemeData defaultThemeData = constructThemeData(
    foreground: ColorPalettes.indigo,
    background: ColorPalettes.neutral,
    brightness: Brightness.dark,
  );

  static ThemeData constructThemeData({
    required final ColorPalette foreground,
    required final ColorPalette background,
    required final Brightness brightness,
    final String fontFamily = defaultFontFamily,
  }) {
    final Color backgroundColorLevel0 =
        background.getColorFromBrightness(brightness);

    final Color backgroundColorLevel1 =
        background.getColorFromBrightness(brightness, 1);

    return ThemeData(
      colorScheme: ColorScheme.fromSwatch(
        brightness: brightness,
        primarySwatch: foreground.asMaterialColor,
        accentColor: foreground.c500,
        cardColor: backgroundColorLevel1,
        backgroundColor: backgroundColorLevel0,
      ),
      fontFamily: fontFamily,
      useMaterial3: true,
      // NOTE: Below properties are workarounds until
      // https://github.com/flutter/flutter/issues/91772 is resolved.
      appBarTheme: AppBarTheme(backgroundColor: backgroundColorLevel1),
      bottomAppBarColor: backgroundColorLevel1,
      scaffoldBackgroundColor: backgroundColorLevel0,
      toggleableActiveColor: foreground.c500,
    );
  }
}
