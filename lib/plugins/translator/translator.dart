import './model.dart';
import './languages/en.dart' as en;

class Translator {
  static Map<String, LanguageSentences> languages = {
    for (final lang in [en.Sentences()]) lang.code: lang
  };

  static LanguageSentences t = languages['en']!;

  static void trySetLanguage(String language) {
    final lang = languages[language];
    if (lang != null) {
      t = lang;
    }
  }

  static void setLanguage(String language) {
    final lang = languages[language];
    if (lang == null) throw 'Unknown language: $language';
    t = lang;
  }
}
