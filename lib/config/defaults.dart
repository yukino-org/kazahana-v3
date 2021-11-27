import '../modules/app/state.dart';

abstract class Defaults {
  static const Duration notifyInfoDuration = Duration(seconds: 2);
  static const Duration mouseOverlayDuration = Duration(seconds: 3);

  static const Duration _noAnimation = Duration(microseconds: 1);
  static const Duration _animationsSlower = Duration(milliseconds: 300);
  static const Duration _animationsSlow = Duration(milliseconds: 250);
  static const Duration _animationsNormal = Duration(milliseconds: 200);
  static const Duration _animationsFast = Duration(milliseconds: 150);
  static const Duration _animationsFaster = Duration(milliseconds: 100);

  static Duration get animationsSlower =>
      AppState.settings.value.disableAnimations
          ? _noAnimation
          : _animationsSlower;

  static Duration get animationsSlow =>
      AppState.settings.value.disableAnimations
          ? _noAnimation
          : _animationsSlow;

  static Duration get animationsNormal =>
      AppState.settings.value.disableAnimations
          ? _noAnimation
          : _animationsNormal;

  static Duration get animationsFast =>
      AppState.settings.value.disableAnimations
          ? _noAnimation
          : _animationsFast;

  static Duration get animationsFaster =>
      AppState.settings.value.disableAnimations
          ? _noAnimation
          : _animationsFaster;

  static const Duration cachedAnimeInfoExpireTime = Duration(days: 1);
  static const Duration cachedMangaInfoExpireTime = Duration(days: 1);
}
