import 'package:flutter/scheduler.dart';
import 'package:kazahana/core/exports.dart';
import 'relative_size.dart';

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

  ThemeData getThemeData(final BuildContext context) {
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
    final TextTheme textTheme = defaultTextTheme
        .merge(
          TextTheme(
            displayLarge: TextStyle(fontSize: context.r.size(4.8)),
            displayMedium: TextStyle(fontSize: context.r.size(3)),
            displaySmall: TextStyle(fontSize: context.r.size(2.4)),
            headlineLarge: TextStyle(fontSize: context.r.size(2)),
            headlineMedium: TextStyle(fontSize: context.r.size(1.3)),
            headlineSmall: TextStyle(fontSize: context.r.size(1.2)),
            titleLarge: TextStyle(fontSize: context.r.size(1.1)),
            titleMedium: TextStyle(fontSize: context.r.size(0.73)),
            titleSmall: TextStyle(fontSize: context.r.size(0.64)),
            bodyLarge: TextStyle(fontSize: context.r.size(0.75)),
            bodyMedium: TextStyle(fontSize: context.r.size(0.65)),
            bodySmall: TextStyle(fontSize: context.r.size(0.55)),
            labelLarge: TextStyle(fontSize: context.r.size(0.63)),
            labelMedium: TextStyle(fontSize: context.r.size(0.55)),
            labelSmall: TextStyle(fontSize: context.r.size(0.5)),
          ),
        )
        .apply(
          fontFamily: fontFamily,
          bodyColor: backgroundContrastColor,
          displayColor: backgroundContrastColor,
        );

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
      textTheme: textTheme,
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
      dialogBackgroundColor: backgroundColorLevel1,
    );
  }

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

  static const ColorPalette defaultForeground = ColorPalettes.indigo;
  static const ColorPalette defaultBackground = ColorPalettes.neutral;
  static const Brightness defaultBrightness = Brightness.dark;
  static const String defaultFontFamily = Fonts.inter;
}
