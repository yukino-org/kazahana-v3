import 'package:hetu_script/hetu_script.dart';

const String regexDefinitions = '''
external class RegExpMatchResult {
  const input: str;
  fun group(group: num); // -> String?
}
external fun regexMatch(regex: str, text: str); // -> RegExpMatchResult?
external fun regexMatchAll(regex: str, text: str) -> List<RegExpMatchResult>;
external fun regexReplaceAll(data: str, from: str, to: str) -> str;
external fun regexReplaceFirst(data: str, from: str, to: str) -> str;
''';

class RegExpMatchResult {
  RegExpMatchResult({
    required final this.input,
    required final this.group,
  });

  factory RegExpMatchResult.fromRegExpMatch(final RegExpMatch match) =>
      RegExpMatchResult(
        input: match.input,
        group: match.group,
      );

  final String input;
  final String? Function(int) group;
}

class RegExpMatchResultClassBinding extends HTExternalClass {
  RegExpMatchResultClassBinding() : super('RegExpMatchResult');

  @override
  dynamic instanceMemberGet(final dynamic object, final String varName) {
    final RegExpMatchResult element = object as RegExpMatchResult;
    switch (varName) {
      case 'input':
        return element.input;

      case 'group':
        return ({
          final List<dynamic> positionalArgs = const <dynamic>[],
          final Map<String, dynamic> namedArgs = const <String, dynamic>{},
          final List<HTType> typeArgs = const <HTType>[],
        }) =>
            element.group(positionalArgs.first as int);

      default:
        throw HTError.undefined(varName);
    }
  }
}

RegExpMatchResult? regexMatch(final String regex, final String text) {
  final RegExpMatch? match = RegExp(regex).firstMatch(text);
  return match != null ? RegExpMatchResult.fromRegExpMatch(match) : null;
}

List<RegExpMatchResult> regexMatchAll(final String regex, final String text) =>
    RegExp(regex)
        .allMatches(text)
        .map((final RegExpMatch x) => RegExpMatchResult.fromRegExpMatch(x))
        .toList();

String regexReplaceFirst(
  final String data,
  final String from,
  final String to,
) =>
    data.replaceFirst(RegExp(from), to);

String regexReplaceAll(
  final String data,
  final String from,
  final String to,
) =>
    data.replaceAll(RegExp(from), to);
