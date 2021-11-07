import 'dart:io';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import '../../../../utils/http.dart';
import '../html_dom.dart';

class FlutterWebview extends HtmlDOMProvider {
  late final FlutterWebviewPlugin webview;

  @override
  Future<void> initialize() async {
    webview = FlutterWebviewPlugin();
    ready = true;
  }

  @override
  Future<void> goto(final String url) async {
    isClean = false;

    await webview.launch(
      url,
      hidden: true,
      userAgent: HttpUtils.userAgent,
      useWideViewPort: true,
    );
  }

  @override
  Future<dynamic> evalJavascript(final String code) async =>
      webview.evalJavascript(code);

  @override
  Future<void> clean() async {
    if (!isClean) {
      await webview.close();
      isClean = true;
    }
  }

  @override
  Future<void> dispose() async {
    webview.dispose();
  }

  static bool isSupported() => Platform.isAndroid || Platform.isIOS;
}
