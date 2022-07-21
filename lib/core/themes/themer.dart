import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
        brightness: SettingsDatabase.settings.useSystemPreferredTheme
            ? SchedulerBinding.instance.window.platformBrightness
            : SettingsDatabase.settings.darkMode
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
    final Color backgroundColorLevel2 =
        background.getColorFromBrightness(brightness, 2);

    final Color foregroundContrastColor =
        background.getColorFromBrightness(Brightness.light);
    final Color backgroundContrastColor =
        background.getColorFromBrightness(brightness, 9);

    final Typography defaultTypography = Typography.material2021();
    final TextTheme defaultTextTheme = brightness == Brightness.light
        ? defaultTypography.black
        : defaultTypography.white;

    return ThemeData(
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: foreground.c500,
        onPrimary: foregroundContrastColor,
        secondary: foreground.c500,
        onSecondary: backgroundContrastColor,
        background: background.c500,
        onBackground: backgroundContrastColor,
        error: Colors.red,
        onError: foregroundContrastColor,
        surface: backgroundColorLevel0,
        onSurface: backgroundContrastColor,
      ),
      textTheme: defaultTextTheme.apply(
        fontFamily: fontFamily,
        bodyColor: backgroundContrastColor,
        displayColor: backgroundContrastColor,
      ),
      useMaterial3: true,
      // ? Below properties are workarounds until
      // ? https://github.com/flutter/flutter/issues/91772 is resolved.
      appBarTheme: AppBarTheme(backgroundColor: backgroundColorLevel1),
      bottomAppBarColor: backgroundColorLevel1,
      scaffoldBackgroundColor: backgroundColorLevel0,
      toggleableActiveColor: foreground.c500,
      bottomSheetTheme:
          BottomSheetThemeData(backgroundColor: backgroundColorLevel1),
      canvasColor: backgroundColorLevel2,
    );
  }

  static const ColorPalette defaultForeground = ColorPalettes.indigo;
  static const ColorPalette defaultBackground = ColorPalettes.neutral;
  static const Brightness defaultBrightness = Brightness.dark;
  static const String defaultFontFamily = Fonts.inter;
}
