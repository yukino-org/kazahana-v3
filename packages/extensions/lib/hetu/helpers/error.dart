const String errorDefinitions = '''
external fun throwError(err: str) -> void;
''';

void throwError(final String err) => throw err;
