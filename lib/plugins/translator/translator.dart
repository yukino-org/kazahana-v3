import 'dart:io' show Platform;
import '../../core/models/languages.dart';
import '../../core/models/translations.dart';
import './translations/en.dart' as en;

abstract class Translator {
  static final List<TranslationSentences> _availableTranslations = [
    en.Sentences(),
  ];

  static Map<String, TranslationSentences> translations = {
    for (final lang in _availableTranslations) lang.code.code: lang,
  };

  static late TranslationSentences t;

  static void setLanguage(final String language) {
    final lang = translations[language];
    if (lang == null) throw ('Unknown language: $language');
    t = lang;
  }

  static bool isSupportedLocale(String locale) => translations[locale] != null;

  static String getSupportedLocale() {
    final sysLang = Platform.localeName.split('_')[0];
    return isSupportedLocale(sysLang) ? sysLang : LanguageCodes.en.code;
  }
}
