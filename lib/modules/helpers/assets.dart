import 'package:flutter/material.dart';
import './ui.dart';

abstract class Assets {
  static const String yukinoIcon = 'assets/images/yukino-icon.png';

  static const String lightPlaceHolderImage =
      'assets/images/light-placeholder-image.png';
  static const String darkPlaceHolderImage =
      'assets/images/dark-placeholder-image.png';

  static const String anilistLogo = 'assets/images/anilist-logo.png';
  static const String myAnimeListLogo = 'assets/images/myanimelist-logo.png';

  static String placeholderImage({
    required final bool dark,
  }) =>
      dark ? darkPlaceHolderImage : lightPlaceHolderImage;

  static String placeholderImageFromContext(final BuildContext context) =>
      placeholderImage(dark: UiUtils.isDarkContext(context));
}
