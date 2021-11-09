import 'dart:io';

abstract class HttpUtils {
  static const String userAgentWindows =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36';
  static const String userAgentLinux =
      'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36';
  static const String userAgentMacOS =
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/11.1.2 Safari/605.1.15';

  static String get userAgent => Platform.isWindows
      ? userAgentWindows
      : Platform.isMacOS
          ? userAgentMacOS
          : userAgentLinux;

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
    try {
      if (url != Uri.decodeFull(url)) return url;
    } catch (_) {}

    return Uri.encodeFull(url);
  }

  static String domainFromURL(final String url) =>
      RegExp(r':\/\/([^\/]+)').firstMatch(url)?[1] ?? url.substring(0, 10);

  static String ensureURL(final String url) =>
      tryEncodeURL(ensureProtocol(url));
}
