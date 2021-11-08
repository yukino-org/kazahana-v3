import 'dart:io';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../html_dom.dart';

class FlutterWebviewProvider extends HtmlDOMProvider {
  CookieManager? cookies = CookieManager.instance();

  @override
  Future<void> initialize() async {
    ready = true;
  }

  @override
  Future<HtmlDOMTab> create() async {
    HeadlessInAppWebView? webview = HeadlessInAppWebView();

    return HtmlDOMTab(
      HtmlDOMTabImpl(
        open: (final String url) async {
          await webview!.webViewController
              .loadUrl(urlRequest: URLRequest(url: Uri.parse(url)));
        },
        evalJavascript: (final String code) =>
            webview!.webViewController.evaluateJavascript(source: code),
        getHtml: () => webview!.webViewController.getHtml(),
        getCookies: (final String url) async {
          final List<Cookie> got =
              await cookies!.getCookies(url: Uri.parse(url));

          return got.asMap().map(
                (final int i, final Cookie x) =>
                    MapEntry<String, String>(x.name, x.value.toString()),
              );
        },
        deleteCookie: (final String url, final String name) =>
            cookies!.deleteCookie(url: Uri.parse(url), name: name),
        clearAllCookies: () => cookies!.deleteAllCookies(),
        dispose: () async {
          await webview?.dispose();
          webview = null;
        },
      ),
    );
  }

  @override
  Future<void> dispose() async {
    cookies = null;
  }

  static bool isSupported() => Platform.isAndroid || Platform.isIOS;
}
