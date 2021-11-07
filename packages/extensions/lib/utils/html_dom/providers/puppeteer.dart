import 'dart:io';
import 'package:puppeteer/puppeteer.dart';
import '../html_dom.dart';

class Puppeteer extends HtmlDOMProvider {
  late Browser browser;
  Page? page;
  String? chromiumPath;

  @override
  Future<void> initialize() async {
    final List<String?> chromiumPaths = <String?>[
      ...await Puppeteer.getChromiumPaths(),
      null,
    ];

    for (final String? x in chromiumPaths) {
      try {
        await _launch(x);
        break;
      } catch (_) {}
    }

    ready = true;
  }

  Future<void> _launch(final String? executablePath) async {
    browser = await puppeteer.launch(
      executablePath: executablePath,
    );

    chromiumPath = executablePath;
  }

  @override
  Future<void> goto(final String url) async {
    isClean = false;

    page = await browser.newPage();
    await page!.goto(url);
  }

  @override
  Future<dynamic> evalJavascript(final String code) async =>
      page?.evaluate(code);

  @override
  Future<void> clean() async {
    if (!isClean) {
      await page?.close();
      isClean = true;
    }
  }

  @override
  Future<void> dispose() async {
    await browser.close();
  }

  bool get isUsingInbuiltBrowser => chromiumPath != null;

  static const List<String> regKeys = <String>[
    r'HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\App Paths',
    r'HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\App Paths',
  ];

  static final RegExp chromiumAppMatcher =
      RegExp(r'\(Default\)\s+REG_SZ\s+(.*?\\(chrome|msedge)\.exe)');

  static bool isSupported() =>
      Platform.isWindows || Platform.isLinux || Platform.isMacOS;

  static Future<List<String>> getChromiumPaths() async {
    final List<String> chromiumPaths = <String>[];

    for (final String regKey in regKeys) {
      final ProcessResult result = await Process.run(
        'REG',
        <String>['QUERY', regKey, '/s'],
        runInShell: true,
      );

      chromiumPaths.addAll(
        chromiumAppMatcher
            .allMatches(result.stdout.toString())
            .map((final RegExpMatch x) => x.group(1)!),
      );
    }

    return chromiumPaths;
  }
}
