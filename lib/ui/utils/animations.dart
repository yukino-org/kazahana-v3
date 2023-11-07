import 'package:kazahana/core/exports.dart';

abstract class AnimationDurations {
  static const Duration _defaultQuickAnimation = Duration(milliseconds: 100);
  static const Duration _defaultNormalAnimation = Duration(milliseconds: 300);
  static const Duration _defaultLongAnimation = Duration(milliseconds: 500);

  static Duration onlyIfEnabled(final Duration duration) =>
      disabled ? Duration.zero : duration;

  static bool get disabled =>
      SettingsDatabase.ready && SettingsDatabase.settings.disableAnimations;

  static Duration get defaultQuickAnimation =>
      onlyIfEnabled(_defaultQuickAnimation);

  static Duration get defaultNormalAnimation =>
      onlyIfEnabled(_defaultNormalAnimation);

  static Duration get defaultLongAnimation =>
      onlyIfEnabled(_defaultLongAnimation);
}
