import 'dart:io';
import 'package:utilx/utilities/locale.dart';
import './translations/en.dart' as en;
import './translations/pt_br.dart' as pt_br;
import './translations/es.dart' as es;
import 'translations.dart';

abstract class Translator {
  static final List<TranslationSentences> translations = <TranslationSentences>[
    en.Sentences(),
    pt_br.Sentences(),
    es.Sentences(),
  ];

  static late TranslationSentences t;

  static TranslationSentences? tryGetTranslation(final String _locale) {
    final Locale? locale = Locale.tryParse(_locale);

    if (locale != null) {
      TranslationSentences? translation;
      int threshold = 0;

      for (final TranslationSentences x in translations) {
        final int nThresh = x.locale.compare(locale);
        if (nThresh > threshold) {
          translation = x;
          threshold = nThresh;
        }
      }

      return translation;
    }
  }

  static TranslationSentences getDefaultTranslation() =>
      translations.firstWhere(
        (final TranslationSentences x) => x.locale == Locale(LanguageCodes.en),
      );

  static TranslationSentences getSupportedTranslation() =>
      tryGetTranslation(Platform.localeName) ?? getDefaultTranslation();
}
