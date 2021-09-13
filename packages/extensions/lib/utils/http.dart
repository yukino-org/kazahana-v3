abstract class HttpUtils {
  static const String userAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36';

  static const Duration timeout = Duration(seconds: 10);
  static const Duration extendedTimeout = Duration(seconds: 20);
  static const String contentTypeURLEncoded =
      'application/x-www-form-urlencoded; charset=UTF-8';

  static String ensureHTTPS(final String url) =>
      url.startsWith('http:') ? url.replaceFirst('http:', 'https:') : url;

  static String ensureProtocol(final String url, {final bool https = true}) =>
      !url.startsWith('http')
          ? https
              ? 'https:$url'
              : 'http:$url'
          : url;

  static String tryEncodeURL(final String url) {
    if (url == Uri.decodeFull(url)) return Uri.encodeFull(url);
    return url;
  }

  static String domainFromURL(final String url) =>
      RegExp(r':\/\/([^\/]+)').firstMatch(url)?[1] ?? url.substring(0, 10);
}
