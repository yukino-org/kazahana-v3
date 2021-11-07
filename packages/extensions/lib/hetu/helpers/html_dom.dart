import 'package:hetu_script/hetu_script.dart';
import '../../utils/html_dom/html_dom.dart';

const String htmlDomDefinitions = '''
external class HtmlDOM {
  fun getHtml(); // -> Future<String?>
  fun evalJavascript(code: str); // -> Future<dynamic>
}
external fun createDOM(url: str) // -> Future<HtmlDOM>;
''';

class HtmlDOM {
  HtmlDOM({
    required final this.getHtml,
    required final this.evaluateJavascript,
  });

  factory HtmlDOM.fromProvider(final HtmlDOMProvider provider) => HtmlDOM(
        getHtml: provider.getHtml,
        evaluateJavascript: provider.evalJavascript,
      );

  final Future<String?> Function() getHtml;
  final Future<dynamic> Function(String) evaluateJavascript;
}

class HtmlDOMClassBinding extends HTExternalClass {
  HtmlDOMClassBinding() : super('HtmlDOM');

  @override
  dynamic instanceMemberGet(final dynamic object, final String varName) {
    final HtmlDOM dom = object as HtmlDOM;
    switch (varName) {
      case 'getHtml':
        return ({
          final List<dynamic> positionalArgs = const <dynamic>[],
          final Map<String, dynamic> namedArgs = const <String, dynamic>{},
          final List<HTType> typeArgs = const <HTType>[],
        }) =>
            dom.getHtml();

      case 'evaluateJavascript':
        return ({
          final List<dynamic> positionalArgs = const <dynamic>[],
          final Map<String, dynamic> namedArgs = const <String, dynamic>{},
          final List<HTType> typeArgs = const <HTType>[],
        }) =>
            dom.evaluateJavascript(positionalArgs.first as String);

      default:
        throw HTError.undefined(varName);
    }
  }
}

Future<HtmlDOM> createDOM(final String url) async {
  await HtmlDOMManager.provider.goto(url);
  return HtmlDOM.fromProvider(HtmlDOMManager.provider);
}
