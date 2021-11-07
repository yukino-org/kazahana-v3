import './providers/flutter_webview_plugin.dart';
import './providers/puppeteer.dart';

class HtmlDOMOptions {
  const HtmlDOMOptions({
    required final this.puppeteerOptions,
  });

  final PuppeteerOptions puppeteerOptions;
}

abstract class HtmlDOMProvider {
  HtmlDOMProvider(this.options);

  final HtmlDOMOptions options;
  bool isClean = false;

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

  static Future<void> initialize(final HtmlDOMOptions options) async {
    if (FlutterWebview.isSupported()) {
      provider = FlutterWebview(options);
    } else if (Puppeteer.isSupported()) {
      provider = Puppeteer(options);
    } else {
      throw Exception('No DOM provider was found');
    }

    await provider.initialize();
  }

  static Future<void> dispose() async {
    await provider.dispose();
  }
}
