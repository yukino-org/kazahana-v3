import './html_dom.dart';

abstract class HtmlDOMUtils {
  static const Duration cloudflareCheckDuration = Duration(seconds: 6);

  static bool isBlockedByCloudflare(final String html) {
    final String htmlLwr = html.toLowerCase();

    return <String>[
      'id="cf-wrapper"',
    ].every((final String x) => htmlLwr.contains(x));
  }

  static Future<bool> tryBypassCloudflare(final HtmlDOMTab tab) async {
    final List<Duration> checkIntervals = <Duration>[
      Duration.zero,
      cloudflareCheckDuration,
      ...List<Duration>.generate(
        5,
        (final int i) => Duration(seconds: i + 1),
      ),
    ];

    for (final Duration i in checkIntervals) {
      await Future<void>.delayed(i);

      final String? html = await tab.getHtml();
      if (html != null && !isBlockedByCloudflare(html)) {
        return true;
      }
    }

    return false;
  }
}
