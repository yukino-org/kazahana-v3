import 'package:utilx/generated/locale.g.dart';

const String languagesDefinitions = '''
external fun isValidLanguage(lang: str) -> bool;
external fun allLanguages() -> List<str>;
''';

final List<String> _languages = LanguageUtils.nameCodeMap.keys.toList();

bool isValidLanguages(final String language) => _languages.contains(language);

List<String> allLanguages() => _languages;
