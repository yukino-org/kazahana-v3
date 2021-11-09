import 'package:hetu_script/hetu_script.dart';

const String errorDefinitions = '''
external class TaskTrace {
  fun add(line: str); // -> void
  fun toString() -> str;
}

external fun throwError(err: str, [trace]); // (String, TaskTrace?) -> never
''';

void throwError(final String err, [final HetuTaskTrace? trace]) {
  throw _HetuErrorWithTaskTrace(err, trace);
}

class _HetuErrorWithTaskTrace implements Error {
  _HetuErrorWithTaskTrace(this.err, [this.trace]);

  final String err;
  final HetuTaskTrace? trace;

  @override
  StackTrace? get stackTrace => StackTrace.fromString(trace.toString());
}

class HetuTaskTrace {
  int _n = 0;
  final List<String> _traces = <String>[];

  void add(final String line) {
    _traces.add('#$_n $line');
    _n++;
  }

  @override
  String toString() => _traces.join('\n');
}

class HetuTaskTraceClassBinding extends HTExternalClass {
  HetuTaskTraceClassBinding() : super('TaskTrace');

  @override
  dynamic instanceMemberGet(final dynamic object, final String varName) {
    final HetuTaskTrace element = object as HetuTaskTrace;
    switch (varName) {
      case 'add':
        return ({
          final List<dynamic> positionalArgs = const <dynamic>[],
          final Map<String, dynamic> namedArgs = const <String, dynamic>{},
          final List<HTType> typeArgs = const <HTType>[],
        }) =>
            element.add(positionalArgs.first as String);

      case 'toString':
        return element.toString();

      default:
        throw HTError.undefined(varName);
    }
  }
}
