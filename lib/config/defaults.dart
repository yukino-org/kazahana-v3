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
      isAnimationsDisabled ? _noAnimation : _animationsSlower;

  static Duration get animationsSlow =>
      isAnimationsDisabled ? _noAnimation : _animationsSlow;

  static Duration get animationsNormal =>
      isAnimationsDisabled ? _noAnimation : _animationsNormal;

  static Duration get animationsFast =>
      isAnimationsDisabled ? _noAnimation : _animationsFast;

  static Duration get animationsFaster =>
      isAnimationsDisabled ? _noAnimation : _animationsFaster;

  static bool get isAnimationsDisabled =>
      AppState.settings.value.developers.disableAnimations;

  static const Duration cachedAnimeInfoExpireTime = Duration(days: 1);
  static const Duration cachedMangaInfoExpireTime = Duration(days: 1);
}
