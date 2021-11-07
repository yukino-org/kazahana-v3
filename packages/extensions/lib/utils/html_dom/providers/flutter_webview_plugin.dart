import 'dart:io';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import '../../../../utils/http.dart';
import '../html_dom.dart';

class FlutterWebviewTab extends HtmlDOMTab {
  FlutterWebviewTab(this.webview) : super();

  FlutterWebviewPlugin? webview;

  @override
  Future<void> open(final String url) async {
    beforeMethod();

    await webview!.launch(
      url,
      hidden: true,
      userAgent: HttpUtils.userAgent,
      useWideViewPort: true,
    );
  }

  @override
  Future<dynamic> evalJavascript(final String code) async {
    beforeMethod();

    return webview!.evalJavascript(code);
  }

  @override
  Future<Map<String, String>> getCookies() async {
    beforeMethod();

    return webview!.getCookies();
  }

  @override
  Future<void> clearCookies() async {
    beforeMethod();

    return webview!.cleanCookies();
  }

  @override
  Future<void> dispose() async {
    await webview!.close();
    webview = null;

    super.dispose();
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
