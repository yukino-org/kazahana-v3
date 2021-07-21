import 'dart:io' show Platform;
import './model.dart';
import './languages/en.dart' as en;

abstract class Translator {
  static Map<String, LanguageSentences> languages = {
    for (final lang in [en.Sentences()]) lang.code.code: lang,
  };

  static late LanguageSentences t;

  static LanguageCodes getCodeFromLanguage(final String language) {
    for (final lang in LanguageCodes.values) {
      if (lang.code == language) return lang;
    }

    throw ('Unknown language: $language');
  }

  static void setLanguage(final String language) {
    final lang = languages[language];
    if (lang == null) throw ('Unknown language: $language');
    t = lang;
  }

  static bool isSupportedLocale(String locale) => languages[locale] != null;

  static String getSupportedLocale() {
    final sysLang = Platform.localeName.split('_')[0];
    return isSupportedLocale(sysLang) ? sysLang : LanguageCodes.en.code;
  }
}
