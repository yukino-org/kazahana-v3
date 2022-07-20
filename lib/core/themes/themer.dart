import 'package:flutter/material.dart';
import '../database/exports.dart';
import 'colors.dart';
import 'fonts.dart';

abstract class Themer {
  static ColorPalette _findColor(
    final String? color,
    final ColorPalette fallback,
  ) {
    if (color == null) return fallback;
    return ColorPalettes.find(color) ?? fallback;
  }

  static ThemerThemeData getCurrentTheme() => ThemerThemeData(
        foreground: _findColor(
          SettingsDatabase.settings.primaryColor,
          ThemerThemeData.defaultForeground,
        ),
        background: _findColor(
          SettingsDatabase.settings.backgroundColor,
          ThemerThemeData.defaultBackground,
        ),
        brightness: SettingsDatabase.settings.darkMode
            ? Brightness.dark
            : Brightness.light,
      );

  static ThemerThemeData defaultTheme() => const ThemerThemeData();
}

class ThemerThemeData {
  const ThemerThemeData({
    this.foreground = defaultForeground,
    this.background = defaultBackground,
    this.brightness = defaultBrightness,
    this.fontFamily = defaultFontFamily,
  });

  final ColorPalette foreground;
  final ColorPalette background;
  final Brightness brightness;
  final String fontFamily;

  @override
  int get hashCode =>
      Object.hash(foreground, background, brightness, fontFamily);

  @override
  bool operator ==(final Object other) =>
      other is ThemerThemeData &&
      foreground.name == other.foreground.name &&
      background.name == other.background.name &&
      brightness.name == other.brightness.name &&
      fontFamily == other.fontFamily;

  ThemeData get asThemeData {
    final Color backgroundColorLevel0 =
        background.getColorFromBrightness(brightness);
    final Color backgroundColorLevel1 =
        background.getColorFromBrightness(brightness, 1);

    final Color lightColor = background.c0;
    final Color darkColor = background.c900;
    final Color contrastColor =
        brightness == Brightness.light ? darkColor : lightColor;

    return ThemeData(
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: foreground.c500,
        onPrimary: lightColor,
        secondary: foreground.c500,
        onSecondary: contrastColor,
        background: background.c500,
        onBackground: contrastColor,
        error: Colors.red,
        onError: contrastColor,
        surface: backgroundColorLevel0,
        onSurface: contrastColor,
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

  static const ColorPalette defaultForeground = ColorPalettes.indigo;
  static const ColorPalette defaultBackground = ColorPalettes.neutral;
  static const Brightness defaultBrightness = Brightness.dark;
  static const String defaultFontFamily = Fonts.inter;
}
