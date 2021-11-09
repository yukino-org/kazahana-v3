import './html_dom.dart';

abstract class HtmlDOMUtils {
  static const Duration _cloudflareCheckDuration = Duration(seconds: 6);
  static const Duration _cloudflarePostCheckDuration = Duration(seconds: 1);

  static bool _isItCloudflareCheck(final String html) {
    final String _html = html.toLowerCase();

    return <String>[
      'id="cf-wrapper"',
      'checking your browser',
    ].every((final String x) => _html.contains(x));
  }

  static Future<bool> tryBypassCloudflare(final HtmlDOMTab tab) async {
    final List<Duration> checkIntervals = <Duration>[
      Duration.zero,
      _cloudflareCheckDuration,
      ...List<Duration>.generate(
        3,
        (final int _) => _cloudflarePostCheckDuration,
      ),
    ];

    for (final Duration i in checkIntervals) {
      await Future<void>.delayed(i);

      final String? html = await tab.getHtml();
      if (html != null && !_isItCloudflareCheck(html)) {
        return true;
      }
    }

    return false;
  }
}
