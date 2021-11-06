const String errorDefinitions = '''
external fun throwError(err: str); // -> never
''';

void throwError(final String err) => throw err;
