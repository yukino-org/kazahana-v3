abstract class Assets {
  static String placeholderImage({
    required final bool dark,
  }) =>
      dark
          ? 'assets/images/dark-placeholder-image.png'
          : 'assets/images/light-placeholder-image.png';
}
