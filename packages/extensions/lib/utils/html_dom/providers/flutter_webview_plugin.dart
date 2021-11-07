import 'dart:io';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import '../../../../utils/http.dart';
import '../html_dom.dart';

class FlutterWebviewTab extends HtmlDOMTab {
  FlutterWebviewTab(this.webview) : super();

  FlutterWebviewPlugin? webview;

  @override
  Future<void> open(final String url) async {
    await webview!.launch(
      url,
      hidden: true,
      userAgent: HttpUtils.userAgent,
      useWideViewPort: true,
    );
  }

  @override
  Future<dynamic> evalJavascript(final String code) async =>
      webview!.evalJavascript(code);

  @override
  Future<Map<String, String>> getCookies() async => webview!.getCookies();

  @override
  Future<void> clearCookies() async => webview!.cleanCookies();

  @override
  Future<void> dispose() async {
    await webview!.close();
    webview = null;
  }
}

class FlutterWebviewProvider extends HtmlDOMProvider {
  @override
  Future<void> initialize() async {
    ready = true;
  }

  @override
  Future<FlutterWebviewTab> create() async =>
      FlutterWebviewTab(FlutterWebviewPlugin());

  @override
  Future<void> dispose() async {}

  static bool isSupported() => Platform.isAndroid || Platform.isIOS;
}
