import 'dart:async';
import './providers/flutter_webview_plugin.dart';
import './providers/puppeteer.dart';

abstract class HtmlDOMTab {
  HtmlDOMTab() {
    Timer.periodic(expireCheckDuration, (final Timer timer) async {
      if (lastUsed == null ||
          DateTime.now().millisecond >
              (lastUsed! + expireDuration.inMilliseconds)) {
        await dispose();
        timer.cancel();
      }
    });
  }

  int? lastUsed;

  Future<void> open(final String url);
  Future<dynamic> evalJavascript(final String code);
  Future<Map<String, String>> getCookies();
  Future<void> clearCookies();

  Future<String?> getHtml() async {
    final dynamic result =
        await evalJavascript('() => document.documentElement.outerHTML;');

    return result is String ? result : null;
  }

  Future<void> dispose();

  static const Duration expireDuration = Duration(minutes: 2);
  static const Duration expireCheckDuration = Duration(minutes: 1);
}

abstract class HtmlDOMProvider {
  bool ready = false;

  Future<void> initialize();
  Future<HtmlDOMTab> create();
  Future<void> dispose();
}

abstract class HtmlDOMManager {
  static late final HtmlDOMProvider provider;

  static Future<void> initialize() async {
    if (FlutterWebviewProvider.isSupported()) {
      provider = FlutterWebviewProvider();
    } else if (PuppeteerProvider.isSupported()) {
      provider = PuppeteerProvider();
    } else {
      throw Exception('No DOM provider was found');
    }

    await provider.initialize();
  }

  static Future<void> dispose() async {
    await provider.dispose();
  }
}
