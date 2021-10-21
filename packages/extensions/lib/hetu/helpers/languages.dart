import 'package:utilx/utilities/languages.dart';

final List<String> _languages = LanguageUtils.languageCodeMap.keys.toList();

bool isValidLanguages(final String language) => _languages.contains(language);

List<String> allLanguages() => _languages;
