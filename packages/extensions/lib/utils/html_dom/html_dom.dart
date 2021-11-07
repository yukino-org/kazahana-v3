import 'dart:async';
import 'package:flutter/material.dart';

import './providers/flutter_webview_plugin.dart';
import './providers/puppeteer.dart';

abstract class HtmlDOMTab {
  int lastUsed = DateTime.now().millisecondsSinceEpoch;
  bool disposed = false;

  late Timer? timer =
      Timer.periodic(expireCheckDuration, (final Timer timer) async {
    if (hasExpired && !disposed) {
      await dispose();
    }
  });

  Future<void> open(final String url);
  Future<dynamic> evalJavascript(final String code);
  Future<Map<String, String>> getCookies();
  Future<void> clearCookies();

  Future<String?> getHtml() async {
    final dynamic result =
        await evalJavascript('() => document.documentElement.outerHTML;');

    return result is String ? result : null;
  }

  @mustCallSuper
  Future<void> dispose() async {
    timer?.cancel();
    timer = null;
    disposed = true;
  }

  void beforeMethod() {
    if (disposed) {
      throw StateError('DOM has been disposed');
    }

    lastUsed = DateTime.now().microsecondsSinceEpoch;
  }

  bool get hasExpired =>
      DateTime.now().millisecondsSinceEpoch >
      (lastUsed + expireDuration.inMilliseconds);

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
