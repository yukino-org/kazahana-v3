import './providers/flutter_webview_plugin.dart';
import './providers/puppeteer.dart';

abstract class HtmlDOMProvider {
  bool isClean = false;
  bool ready = false;

  Future<void> initialize();
  Future<void> goto(final String url);
  Future<dynamic> evalJavascript(final String code);

  Future<String?> getHtml() async {
    final dynamic result =
        await evalJavascript('() => document.documentElement.outerHTML;');

    return result is String ? result : null;
  }

  Future<void> clean();
  Future<void> dispose();
}

abstract class HtmlDOMManager {
  static late final HtmlDOMProvider provider;

  static Future<void> initialize() async {
    if (FlutterWebview.isSupported()) {
      provider = FlutterWebview();
    } else if (Puppeteer.isSupported()) {
      provider = Puppeteer();
    } else {
      throw Exception('No DOM provider was found');
    }

    await provider.initialize();
  }

  static Future<void> dispose() async {
    await provider.dispose();
  }
}
