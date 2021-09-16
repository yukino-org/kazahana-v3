String tryMaxRes(final String url) {
  final RegExpMatch? match =
      RegExp(r'\/images.*\.(jpg|jpeg|png|webp)').firstMatch(url);

  if (match != null) {
    return 'https://cdn.myanimelist.net${match.group(0)}';
  }

  return url;
}
