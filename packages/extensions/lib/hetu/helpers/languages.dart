import 'package:utilx/utilities/languages.dart';

final List<String> _languages = LanguageUtils.codeLangaugeMap.keys.toList();

bool isValidLanguages(final String language) => _languages.contains(language);

List<String> allLanguages() => _languages;
