import 'package:flutter/scheduler.dart';
import 'package:kazahana/core/exports.dart';
import 'relative_scale.dart';

abstract class Themer {
  static Color _findColor(final String? color, final Color fallback) {
    if (color == null) return fallback;
    return ForegroundColors.find(color) ?? fallback;
  }

  static ThemerThemeData getCurrentTheme() {
    final Color foreground = _findColor(
      SettingsDatabase.settings.primaryColor,
      ThemerThemeData.defaultForeground,
    );
    final Brightness brightness =
        SettingsDatabase.settings.useSystemPreferredTheme
            ? SchedulerBinding.instance.platformDispatcher.platformBrightness
            : SettingsDatabase.settings.darkMode
                ? Brightness.dark
                : Brightness.light;
    return ThemerThemeData(foreground: foreground, brightness: brightness);
  }

  static ThemerThemeData defaultTheme() => const ThemerThemeData();
}

class ThemerThemeData {
  const ThemerThemeData({
    this.foreground = defaultForeground,
    this.brightness = defaultBrightness,
    this.fontFamily = defaultFontFamily,
  });

  final Color foreground;
  final Brightness brightness;
  final String fontFamily;

  ThemeData getThemeData(final BuildContext context) {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: foreground,
      brightness: brightness,
    );

    final Typography defaultTypography =
        Typography.material2021(colorScheme: colorScheme);
    final TextTheme defaultTextTheme = brightness == Brightness.light
        ? defaultTypography.black
        : defaultTypography.white;
    final TextTheme textTheme = defaultTextTheme
        .merge(
          TextTheme(
            displayLarge: TextStyle(fontSize: context.r.scale(3.2)),
            displayMedium: TextStyle(fontSize: context.r.scale(3)),
            displaySmall: TextStyle(fontSize: context.r.scale(2.8)),
            headlineLarge: TextStyle(fontSize: context.r.scale(2.6)),
            headlineMedium: TextStyle(fontSize: context.r.scale(2.4)),
            headlineSmall: TextStyle(fontSize: context.r.scale(2.2)),
            titleLarge: TextStyle(fontSize: context.r.scale(1.8)),
            titleMedium: TextStyle(fontSize: context.r.scale(1.6)),
            titleSmall: TextStyle(fontSize: context.r.scale(1.4)),
            bodyLarge: TextStyle(fontSize: context.r.scale(1.2)),
            bodyMedium: TextStyle(fontSize: context.r.scale(1.1)),
            bodySmall: TextStyle(fontSize: context.r.scale(1)),
            labelLarge: TextStyle(fontSize: context.r.scale(0.9)),
            labelMedium: TextStyle(fontSize: context.r.scale(0.8)),
            labelSmall: TextStyle(fontSize: context.r.scale(0.7)),
          ),
        )
        .apply(fontFamily: fontFamily);

    return ThemeData(
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: textTheme,
      useMaterial3: true,
      // ? Below properties are workarounds until
      // ? https://github.com/flutter/flutter/issues/91772 is resolved.
      // appBarTheme: AppBarTheme(backgroundColor: backgroundColorLevel1),
      bottomAppBarTheme: BottomAppBarTheme(color: colorScheme.background),
      // scaffoldBackgroundColor: backgroundColorLevel0,
      // TODO: https://docs.flutter.dev/release/breaking-changes/toggleable-active-color#migration-guide
      // toggleableActiveColor: foreground.c500,
      // canvasColor: backgroundColorLevel2,
      // dialogBackgroundColor: backgroundColorLevel1,
    );
  }

  static const String defaultForegroundName = 'indigo';
  static const Color defaultForeground = ForegroundColors.indigo;
  static const Brightness defaultBrightness = Brightness.dark;
  static const String defaultFontFamily = Fonts.inter;
}
