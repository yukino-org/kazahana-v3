String indentString(final String str, final String prefix) =>
    str.split('\n').map((final String x) => '$prefix$x').join('\n');

String errorToString(final Object err, [final StackTrace? _stackTrace]) {
  final StackTrace? stackTrace =
      _stackTrace ?? (err is Error ? err.stackTrace : null);

  final String trace =
      stackTrace != null ? indentString(stackTrace.toString(), '  ') : '-';

  return '${err.toString()}\nStack Trace:\n$trace';
}
