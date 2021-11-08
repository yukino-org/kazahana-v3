import 'package:hetu_script/hetu_script.dart';
import '../../utils/html_dom/html_dom.dart';

const String htmlDomDefinitions = '''
external class HtmlDOMTab {
  const disposed: bool;
  fun open(url: str, wait: str); // (String, 'none' | 'load' | 'domContentLoaded') -> Future<void>
  fun getHtml(); // -> Future<String?>
  fun evalJavascript(code: str); // -> Future<dynamic>
  fun getCookies(url: str); // -> Future<Map<String, String>>
  fun deleteCookie(url: str, name: str); // -> Future<void>
  fun clearAllCookies(); // -> Future<void>
  fun dispose(); // -> Future<void> /// Dispose if you are going to use it anymore
}
external fun createDOM(); // -> Future<HtmlDOMTab>;
''';

class HtmlDOMTabClassBinding extends HTExternalClass {
  HtmlDOMTabClassBinding() : super('HtmlDOMTab');

  @override
  dynamic instanceMemberGet(final dynamic object, final String varName) {
    final HtmlDOMTab tab = object as HtmlDOMTab;
    switch (varName) {
      case 'disposed':
        return tab.disposed;

      case 'open':
        return ({
          final List<dynamic> positionalArgs = const <dynamic>[],
          final Map<String, dynamic> namedArgs = const <String, dynamic>{},
          final List<HTType> typeArgs = const <HTType>[],
        }) =>
            tab.open(
              positionalArgs.first as String,
              positionalArgs[1] as String,
            );

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
            tab.getCookies(positionalArgs.first as String);

      case 'deleteCookie':
        return ({
          final List<dynamic> positionalArgs = const <dynamic>[],
          final Map<String, dynamic> namedArgs = const <String, dynamic>{},
          final List<HTType> typeArgs = const <HTType>[],
        }) =>
            tab.deleteCookie(
              positionalArgs.first as String,
              positionalArgs[1] as String,
            );

      case 'clearAllCookies':
        return ({
          final List<dynamic> positionalArgs = const <dynamic>[],
          final Map<String, dynamic> namedArgs = const <String, dynamic>{},
          final List<HTType> typeArgs = const <HTType>[],
        }) =>
            tab.clearAllCookies();

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
