import 'package:hetu_script/hetu_script.dart';

const String errorDefinitions = '''
external class TaskTrace {
  construct();
  fun add(line: str); // -> void
  fun toString() -> str;
}

external fun throwError(err: str, [trace]); // (String, TaskTrace?) -> never
''';

void throwError(final String err, [final TaskTrace? trace]) {
  throw _ErrorWithTaskTrace(err, trace);
}

class _ErrorWithTaskTrace implements Error {
  _ErrorWithTaskTrace(this.err, [this.trace]);

  final String err;
  final TaskTrace? trace;

  @override
  StackTrace get stackTrace => StackTrace.fromString(trace.toString());

  @override
  String toString() => 'Error: $err\nTrace: ${trace != null ? '\n${trace!.indentedString()}' : '-'}';
}

class TaskTrace {
  int _n = 0;
  final List<String> _traces = <String>[];

  void add(final String line) {
    _traces.add('#$_n $line');
    _n++;
  }

  String indentedString([final String prefix = '  ']) =>
      _traces.map((final String x) => '$prefix$x').join('\n');

  @override
  String toString() => _traces.join('\n');
}

class HetuTaskTraceClassBinding extends HTExternalClass {
  HetuTaskTraceClassBinding() : super('TaskTrace');

  @override
  dynamic memberGet(
    final String varName, {
    final String from = HTLexicon.global,
    final bool error = true,
  }) {
    switch (varName) {
      case 'TaskTrace':
        return ({
          final List<dynamic> positionalArgs = const <dynamic>[],
          final Map<String, dynamic> namedArgs = const <String, dynamic>{},
          final List<HTType> typeArgs = const <HTType>[],
        }) =>
            TaskTrace();

      default:
        throw HTError.undefined(varName);
    }
  }

  @override
  dynamic instanceMemberGet(final dynamic object, final String varName) {
    final TaskTrace element = object as TaskTrace;
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
