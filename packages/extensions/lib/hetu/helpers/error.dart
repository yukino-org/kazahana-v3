import 'package:hetu_script/hetu_script.dart';

const String errorDefinitions = '''
external class HError {
  construct(err: str, [stack, task]); // (String, String?, TaskTrace?) -> HError

  const err: str;
  const stack; // -> String?
  const task: TaskTrace;
  fun toString() -> str;
}

external class TaskTrace {
  construct();

  fun add(line: str); // -> void
  fun toString() -> str;
}

external fun throwError(err, [trace]); // (String | HError, TaskTrace?) -> never
''';

String indentString(final String str, final String prefix) =>
    str.split('\n').map((final String x) => '$prefix$x').join('\n');

void throwError(final dynamic err, [final TaskTrace? taskTrace]) {
  if (err is HError) {
    throw err.copyWith(err, null, taskTrace);
  }

  final String task = indentString(taskTrace?.toString() ?? '-', '  ');
  throw '$err\nTaskTrace:\n$task';
}

class HError implements Error {
  const HError(this.err, [this.stack, this.task]);

  factory HError.fromError(final Object error, [final StackTrace? trace]) =>
      HError(error.toString(), trace?.toString());

  final String err;
  final String? stack;
  final TaskTrace? task;

  HError copyWith(
    final HError err, [
    final String? stack,
    final TaskTrace? task,
  ]) =>
      HError(err.err, stack ?? err.stack, task ?? err.task);

  String prettyString() => '$err\n$stackTrace';

  @override
  StackTrace get stackTrace {
    final String stackString = indentString(stack?.toString() ?? '-', '  ');
    final String taskString = indentString(task?.toString() ?? '-', '  ');

    return StackTrace.fromString(
      'Stack Trace:\n$stackString\nTask Trace:\n$taskString',
    );
  }

  @override
  String toString() => err;
}

class HErrorClassBinding extends HTExternalClass {
  HErrorClassBinding() : super('HError');

  @override
  dynamic memberGet(
    final String varName, {
    final String from = HTLexicon.global,
    final bool error = true,
  }) {
    switch (varName) {
      case 'HError':
        return ({
          final List<dynamic> positionalArgs = const <dynamic>[],
          final Map<String, dynamic> namedArgs = const <String, dynamic>{},
          final List<HTType> typeArgs = const <HTType>[],
        }) =>
            HError(
              positionalArgs[0] as String,
              positionalArgs[1] as String?,
              positionalArgs[2] as TaskTrace?,
            );

      default:
        throw HTError.undefined(varName);
    }
  }

  @override
  dynamic instanceMemberGet(final dynamic object, final String varName) {
    final HError element = object as HError;
    switch (varName) {
      case 'err':
        return ({
          final List<dynamic> positionalArgs = const <dynamic>[],
          final Map<String, dynamic> namedArgs = const <String, dynamic>{},
          final List<HTType> typeArgs = const <HTType>[],
        }) =>
            element.err;

      case 'stack':
        return ({
          final List<dynamic> positionalArgs = const <dynamic>[],
          final Map<String, dynamic> namedArgs = const <String, dynamic>{},
          final List<HTType> typeArgs = const <HTType>[],
        }) =>
            element.stack;

      case 'task':
        return ({
          final List<dynamic> positionalArgs = const <dynamic>[],
          final Map<String, dynamic> namedArgs = const <String, dynamic>{},
          final List<HTType> typeArgs = const <HTType>[],
        }) =>
            element.task;

      case 'toString':
        return element.toString();

      default:
        throw HTError.undefined(varName);
    }
  }
}

class TaskTrace {
  int _n = 0;
  final List<String> _traces = <String>[];

  void add(final String line) {
    _traces.add('#$_n $line');
    _n++;
  }

  @override
  String toString() => _traces.join('\n');
}

class TaskTraceClassBinding extends HTExternalClass {
  TaskTraceClassBinding() : super('TaskTrace');

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
