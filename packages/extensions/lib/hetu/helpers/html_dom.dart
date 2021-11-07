import 'package:hetu_script/hetu_script.dart';
import '../../utils/html_dom/html_dom.dart';

const String htmlDomDefinitions = '''
external class HtmlDOM {
  const disposed: bool;
  fun getHtml(); // -> Future<String?>
  fun evalJavascript(code: str); // -> Future<dynamic>
  fun getCookies(); // -> Future<Map<String, String>>
  fun clearCookies(); // -> Future<void>
  fun dispose(); // -> Future<void> /// Dispose if you are going to use it anymore
}
external fun createDOM() // -> Future<HtmlDOM>;
''';

class HtmlDOMTabClassBinding extends HTExternalClass {
  HtmlDOMTabClassBinding() : super('HtmlDOMTab');

  @override
  dynamic instanceMemberGet(final dynamic object, final String varName) {
    final HtmlDOMTab tab = object as HtmlDOMTab;
    switch (varName) {
      case 'disposed':
        return tab.disposed;

      case 'getHtml':
        return ({
          final List<dynamic> positionalArgs = const <dynamic>[],
          final Map<String, dynamic> namedArgs = const <String, dynamic>{},
          final List<HTType> typeArgs = const <HTType>[],
        }) =>
            tab.getHtml();

      case 'evalJavascript':
        return ({
          final List<dynamic> positionalArgs = const <dynamic>[],
          final Map<String, dynamic> namedArgs = const <String, dynamic>{},
          final List<HTType> typeArgs = const <HTType>[],
        }) =>
            tab.evalJavascript(positionalArgs.first as String);

      case 'getCookies':
        return ({
          final List<dynamic> positionalArgs = const <dynamic>[],
          final Map<String, dynamic> namedArgs = const <String, dynamic>{},
          final List<HTType> typeArgs = const <HTType>[],
        }) =>
            tab.getCookies();

      case 'clearCookies':
        return ({
          final List<dynamic> positionalArgs = const <dynamic>[],
          final Map<String, dynamic> namedArgs = const <String, dynamic>{},
          final List<HTType> typeArgs = const <HTType>[],
        }) =>
            tab.clearCookies();

      case 'dispose':
        return ({
          final List<dynamic> positionalArgs = const <dynamic>[],
          final Map<String, dynamic> namedArgs = const <String, dynamic>{},
          final List<HTType> typeArgs = const <HTType>[],
        }) =>
            tab.dispose();

      default:
        throw HTError.undefined(varName);
    }
  }
}

Future<HtmlDOMTab> createDOM() async => HtmlDOMManager.provider.create();
