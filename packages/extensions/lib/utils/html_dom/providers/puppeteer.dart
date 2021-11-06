import 'dart:io';
import 'package:puppeteer/puppeteer.dart';
import '../html_dom.dart';

class Puppeteer extends HtmlDOMProvider {
  Puppeteer(final HtmlDOMOptions options) : super(options);

  late final Browser browser;
  late final Page page;
  bool ready = false;

  @override
  Future<void> initialize() async {
    browser = await puppeteer.launch(userDataDir: options.dataDirectory);
    page = await browser.newPage();

    ready = true;
  }

  @override
  Future<void> goto(final String url) async {
    isClean = false;

    await page.goto(url);
  }

  @override
  Future<dynamic> evalJavascript(final String code) async =>
      page.evaluate(code);

  @override
  Future<void> clean() async {
    if (!isClean) {
      await page.close();
      isClean = true;
    }
  }

  @override
  Future<void> dispose() async {
    await browser.close();
  }

  static bool isSupported() =>
      Platform.isWindows || Platform.isLinux || Platform.isMacOS;
}
