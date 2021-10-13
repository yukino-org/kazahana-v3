import 'dart:io' show Platform;
import 'package:utilx/utilities/languages.dart';
import './translations/en.dart' as en;
import '../../core/models/translations.dart';

abstract class Translator {
  static final List<TranslationSentences> _availableTranslations =
      <TranslationSentences>[
    en.Sentences(),
  ];

  static Map<String, TranslationSentences> translations =
      <String, TranslationSentences>{
    for (final TranslationSentences lang in _availableTranslations)
      lang.code.code: lang,
  };

  static late TranslationSentences t;

  static void setLanguage(final String language) {
    final TranslationSentences? lang = translations[language];
    if (lang == null) {
      throw ArgumentError('Unknown language: $language');
    }

    t = lang;
  }

  static bool isSupportedLocale(final String locale) =>
      translations[locale] != null;

  static String getSupportedLocale() {
    final String sysLang = Platform.localeName.split('_')[0];
    return isSupportedLocale(sysLang) ? sysLang : LanguageCodes.en.code;
  }
}
