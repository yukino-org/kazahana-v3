import 'dart:async';
import './providers/flutter_inappwebview.dart';
import './providers/puppeteer.dart';

enum HtmlDOMTabGotoWait {
  none,
  load,
  domContentLoaded,
}

class HtmlDOMTabImpl {
  HtmlDOMTabImpl({
    required final this.open,
    required final this.evalJavascript,
    required final this.getCookies,
    required final this.deleteCookie,
    required final this.clearAllCookies,
    required final this.getHtml,
    required final this.dispose,
  });

  final Future<void> Function(String url, HtmlDOMTabGotoWait wait) open;
  final Future<dynamic> Function(String code) evalJavascript;
  final Future<Map<String, String>> Function(String url) getCookies;
  final Future<void> Function(String url, String name) deleteCookie;
  final Future<void> Function() clearAllCookies;
  final Future<String?> Function() getHtml;
  final Future<void> Function() dispose;
}

class HtmlDOMTab {
  HtmlDOMTab(this._impl);

  int _lastUsed = DateTime.now().millisecondsSinceEpoch;
  bool disposed = false;

  final HtmlDOMTabImpl _impl;
  late final Timer timer =
      Timer.periodic(expireCheckDuration, (final Timer timer) async {
    if (expired && !disposed) {
      await dispose();
      timer.cancel();
      disposed = true;
    }
  });

  void _beforeMethod() {
    if (disposed) {
      throw StateError('DOM has been disposed');
    }

    _lastUsed = DateTime.now().microsecondsSinceEpoch;
  }

  Future<void> open(final String url, final String wait) {
    _beforeMethod();
    return _impl.open(
      url,
      HtmlDOMTabGotoWait.values.firstWhere(
        (final HtmlDOMTabGotoWait x) => x.name == wait,
        orElse: () => HtmlDOMTabGotoWait.load,
      ),
    );
  }

  Future<dynamic> evalJavascript(final String code) {
    _beforeMethod();
    return _impl.evalJavascript(code);
  }

  Future<Map<String, String>> getCookies(final String url) {
    _beforeMethod();
    return _impl.getCookies(url);
  }

  Future<void> deleteCookie(final String url, final String name) {
    _beforeMethod();
    return _impl.deleteCookie(url, name);
  }

  Future<void> clearAllCookies() {
    _beforeMethod();
    return _impl.clearAllCookies();
  }

  Future<String?> getHtml() {
    _beforeMethod();
    return _impl.getHtml();
  }

  Future<void> dispose() async {
    if (!disposed) {
      await _impl.dispose();
      timer.cancel();
      disposed = true;
    }
  }

  bool get expired =>
      DateTime.now().millisecondsSinceEpoch >
      (_lastUsed + expireDuration.inMilliseconds);

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
  static bool ready = false;

  static late final HtmlDOMProvider provider;

  static Future<void> initialize() async {
    if (!ready) {
      if (FlutterWebviewProvider.isSupported()) {
        provider = FlutterWebviewProvider();
      } else if (PuppeteerProvider.isSupported()) {
        provider = PuppeteerProvider();
      } else {
        throw Exception('No DOM provider was found');
      }

      await provider.initialize();
      ready = true;
    }
  }

  static Future<void> dispose() async {
    await provider.dispose();
  }
}
