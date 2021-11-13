import 'dart:io';
import 'package:puppeteer/protocol/network.dart';
import 'package:puppeteer/puppeteer.dart';
import './chrome_finder/chrome_finder.dart';
import '../../../http.dart';
import '../../html_dom.dart';

class PuppeteerProvider extends HtmlDOMProvider {
  Browser? browser;
  BrowserContext? context;
  String? chromePath;

  @override
  Future<void> initialize(final HtmlDOMOptions options) async {
    final String? foundPath = await ChromeFinder.find();

    final List<Future<bool> Function()> tasks = <Future<bool> Function()>[
      if (foundPath != null)
        () async {
          await _launch(foundPath);
          return true;
        },
      () async {
        final RevisionInfo revision =
            await downloadChrome(cachePath: options.localChromiumPath);
        await _launch(revision.executablePath);
        return true;
      }
    ];

    for (final Future<bool> Function() x in tasks) {
      try {
        await x();
        break;
      } catch (_) {}
    }

    ready = true;
  }

  Future<void> _launch(final String executablePath) async {
    browser = await puppeteer.launch(
      executablePath: executablePath,
      args: <String>[
        '--single-process',
        '--no-zygote',
        '--no-sandbox',
      ],
    );

    context = await browser!.createIncognitoBrowserContext();

    chromePath = executablePath;
  }

  @override
  Future<HtmlDOMTab> create() async {
    Page? page = await context!.newPage();
    await page.setUserAgent(HttpUtils.userAgent);

    return HtmlDOMTab(
      HtmlDOMTabImpl(
        open: (final String url, final HtmlDOMTabGotoWait wait) async {
          final Until? until;

          switch (wait) {
            case HtmlDOMTabGotoWait.none:
              until = null;
              break;

            case HtmlDOMTabGotoWait.load:
              until = Until.load;
              break;

            case HtmlDOMTabGotoWait.domContentLoaded:
              until = Until.domContentLoaded;
              break;
          }

          await page!.goto(url, wait: until);
        },
        evalJavascript: (final String code) => page!.evaluate(code),
        getHtml: () async {
          final dynamic result =
              await page!.evaluate('() => document.documentElement.outerHTML');

          return result is String ? result : null;
        },
        getCookies: (final String url) async {
          final Uri uri = Uri.parse(url);
          final String domain = uri.authority;
          final List<Cookie> cookies = await page!.cookies();

          return cookies
              .where(
                (final Cookie x) =>
                    x.domain == domain || '.${x.domain}' == domain,
              )
              .toList()
              .asMap()
              .map(
                (final int i, final Cookie x) =>
                    MapEntry<String, String>(x.name, x.value),
              );
        },
        deleteCookie: (final String url, final String name) async {
          final Uri uri = Uri.parse(url);
          final String domain = uri.authority;
          final List<Cookie> cookies = await page!.cookies();

          await Future.wait(
            cookies.where((final Cookie x) => x.domain == domain).toList().map(
                  (final Cookie x) => page!.deleteCookie(
                    x.name,
                    domain: domain,
                  ),
                ),
          );
        },
        clearAllCookies: () async {
          await Future.wait(
            (await page!.cookies())
                .map((final Cookie x) => page!.deleteCookie(x.name)),
          );
        },
        dispose: () async {
          await page?.close();
          page = null;
        },
      ),
    );
  }

  Future<void> _disposePages(final List<Page> pages) => Future.wait(
        pages.map((final Page x) => x.close()),
      );

  @override
  Future<void> dispose() async {
    if (browser != null) {
      await _disposePages(await context!.pages);
      context!.close();
      context = null;

      await _disposePages(await browser!.pages);
      await browser!.close();
      browser = null;
    }
  }

  static bool isSupported() =>
      Platform.isWindows || Platform.isLinux || Platform.isMacOS;
}
