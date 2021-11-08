import 'dart:async';
import 'dart:io';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../html_dom.dart';

class _FlutterWebviewEventer {
  StreamController<Uri> onLoadController = StreamController<Uri>();
  late Stream<Uri> onLoad = onLoadController.stream;

  Future<T> waitUntil<T>(
    final Stream<T> stream,
    final bool Function(T) fn,
  ) {
    final Completer<T> future = Completer<T>();
    StreamSubscription<T>? sub;

    sub = stream.listen((final T value) {
      if (fn(value)) {
        future.complete(value);
        sub?.cancel();
        sub = null;
      }
    });

    return future.future;
  }

  Future<void> dispose() async {
    await onLoadController.close();
    await onLoad.drain();
  }
}

class FlutterWebviewProvider extends HtmlDOMProvider {
  CookieManager? cookies = CookieManager.instance();
  _FlutterWebviewEventer? eventer = _FlutterWebviewEventer();

  @override
  Future<void> initialize() async {
    ready = true;
  }

  @override
  Future<HtmlDOMTab> create() async {
    HeadlessInAppWebView? webview = HeadlessInAppWebView(
      onLoadStop: (final InAppWebViewController controller, final Uri? uri) {
        if (uri != null) {
          eventer!.onLoadController.add(uri);
        }
      },
    );

    return HtmlDOMTab(
      HtmlDOMTabImpl(
        open: (final String url, final HtmlDOMTabGotoWait wait) async {
          final Uri uri = Uri.parse(url);
          final Completer<void> future = Completer<void>();

          switch (wait) {
            case HtmlDOMTabGotoWait.load:
              await eventer!.waitUntil(
                eventer!.onLoad,
                (final Uri receivedUri) => uri == receivedUri,
              );
              future.complete();
              break;

            case HtmlDOMTabGotoWait.domContentLoaded:
              await eventer!.waitUntil(
                eventer!.onLoad,
                (final Uri receivedUri) => uri == receivedUri,
              );
              await webview?.webViewController.callAsyncJavaScript(
                functionBody: '''
                  return new Promise((resolve) => {
                    if (document.readyState === 'complete') {
                      return resolve();
                    }

                    document.addEventListener('DOMContentLoaded', () => {
                      resolve();
                    });
                  });
                  ''',
              );
              future.complete();
              break;

            case HtmlDOMTabGotoWait.none:
              future.complete();
              break;
          }

          await webview!.webViewController
              .loadUrl(urlRequest: URLRequest(url: uri));

          return future.future;
        },
        evalJavascript: (final String code) async {
          final CallAsyncJavaScriptResult? result = await webview!
              .webViewController
              .callAsyncJavaScript(functionBody: code);

          return result?.value;
        },
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
          await eventer?.dispose();
          webview = eventer = null;
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
