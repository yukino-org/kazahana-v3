import './html_dom.dart';

/// `true` = Needs to be bypassed | `false` = Has been bypassed
typedef HtmlBypassBrowserCheck = bool Function(String);

abstract class HtmlDOMUtils {
  static bool checkCloudflare(final String html) {
    final String htmlLwr = html.toLowerCase();

    return <bool>[
      htmlLwr.contains('id="cf-wrapper"'),
      RegExp('class=".*(cf-browser-verification|cf-im-under-attack).*"')
          .hasMatch(htmlLwr),
    ].contains(true);
  }

  static Future<bool> tryBypassBrowserChecks(
    final HtmlDOMTab tab,
    final HtmlBypassBrowserCheck check,
  ) async {
    final List<Duration> checkIntervals = <Duration>[
      Duration.zero,
      ...List<Duration>.generate(
        5,
        (final int i) => Duration(seconds: i + 1),
      ).reversed,
    ];

    for (final Duration i in checkIntervals) {
      await Future<void>.delayed(i);

      final String? html = await tab.getHtml();
      if (html != null && !check(html)) {
        return true;
      }
    }

    return false;
  }
}
