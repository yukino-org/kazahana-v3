import 'package:hetu_script/hetu_script.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html;

const String htmlDefinitions = '''
external class HtmlElement {
  const classes: List<str>;
  const id; // -> String?
  const text; // -> String?
  const innerHtml: str;
  const outerHtml: str;
  const attributes: Map<str>;
  fun querySelector(selector: str); // -> HtmlElement?
  fun querySelectorAll(selector: str) -> List<HtmlElement>;
}
external fun parseHtml(html: str) -> HtmlElement;
external fun joinCookieMap(cookies: Map<str>) -> str;
''';

Map<String, String> _mapElementAttributes(
  final Map<Object, String> attributes,
) {
  final Map<String, String> result = <String, String>{};

  for (final MapEntry<Object, String> x in attributes.entries) {
    if (x.key is String) {
      result[x.key as String] = x.value;
    }
  }

  return result;
}

class HtmlElement {
  HtmlElement({
    required final this.classes,
    required final this.id,
    required final this.text,
    required final this.innerHtml,
    required final this.outerHtml,
    required final this.attributes,
    required final this.querySelector,
    required final this.querySelectorAll,
  });

  factory HtmlElement.fromElement(final dom.Element ele) => HtmlElement(
        classes: ele.classes.toList(),
        id: ele.id,
        text: ele.text,
        innerHtml: ele.innerHtml,
        outerHtml: ele.outerHtml,
        attributes: _mapElementAttributes(ele.attributes),
        querySelector: (final String selector) {
          final dom.Element? found = ele.querySelector(selector);
          return found != null ? HtmlElement.fromElement(found) : null;
        },
        querySelectorAll: (final String selector) => ele
            .querySelectorAll(selector)
            .map((final dom.Element e) => HtmlElement.fromElement(e))
            .toList(),
      );

  final List<String> classes;
  final String? id;
  final String? text;
  final String innerHtml;
  final String outerHtml;
  final Map<String, String> attributes;
  final HtmlElement? Function(String) querySelector;
  final List<HtmlElement> Function(String) querySelectorAll;
}

class HtmlElementClassBinding extends HTExternalClass {
  HtmlElementClassBinding() : super('HtmlElement');

  @override
  dynamic instanceMemberGet(final dynamic object, final String varName) {
    final HtmlElement element = object as HtmlElement;
    switch (varName) {
      case 'classes':
        return element.classes;

      case 'id':
        return element.id;

      case 'text':
        return element.text;

      case 'innerHtml':
        return element.innerHtml;

      case 'outerHtml':
        return element.outerHtml;

      case 'attributes':
        return element.attributes;

      case 'querySelector':
        return ({
          final List<dynamic> positionalArgs = const <dynamic>[],
          final Map<String, dynamic> namedArgs = const <String, dynamic>{},
          final List<HTType> typeArgs = const <HTType>[],
        }) =>
            element.querySelector(positionalArgs.first as String);

      case 'querySelectorAll':
        return ({
          final List<dynamic> positionalArgs = const <dynamic>[],
          final Map<String, dynamic> namedArgs = const <String, dynamic>{},
          final List<HTType> typeArgs = const <HTType>[],
        }) =>
            element.querySelectorAll(positionalArgs.first as String);

      default:
        throw HTError.undefined(varName);
    }
  }
}

HtmlElement parseHtml(final String _html) {
  final dom.Document document = html.parse(_html);

  return HtmlElement(
    classes: <String>[],
    id: null,
    text: document.text,
    innerHtml: _html,
    outerHtml: _html,
    attributes: _mapElementAttributes(document.attributes),
    querySelector: (final String selector) {
      final dom.Element? found = document.querySelector(selector);
      return found != null ? HtmlElement.fromElement(found) : null;
    },
    querySelectorAll: (final String selector) => document
        .querySelectorAll(selector)
        .map((final dom.Element e) => HtmlElement.fromElement(e))
        .toList(),
  );
}

String joinCookieMap(final Map<dynamic, dynamic> cookies) => cookies
    .cast<String, String>()
    .entries
    .map((final MapEntry<String, String> x) => '${x.key}=${x.value}')
    .join('; ');
