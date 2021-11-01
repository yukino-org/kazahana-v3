import '../generated/locale.g.dart';

export '../generated/locale.g.dart';

class Locale {
  Locale(this.code, [this.country]);

  factory Locale.parse(final String locale) {
    final RegExpMatch match = RegExp('([^_]+)(_(.*))?').firstMatch(locale)!;
    final LanguageCodes lang = LanguageUtils.nameCodeMap[match.group(1)!]!;
    final CountryCodes? country = match.group(3) != null
        ? CountryUtils.nameCodeMap[match.group(3)!]
        : null;

    return Locale(lang, country);
  }

  final LanguageCodes code;
  final CountryCodes? country;

  int compare(final Locale locale) {
    int threshold = 0;

    if (locale.code == code) {
      threshold += 1;
    }

    if (locale.country == country) {
      threshold += 2;
    }

    return threshold;
  }

  String toPrettyString() => <String>[
        code.language,
        if (country != null) '(${country!.country})'
      ].join(' ');

  @override
  String toString() =>
      <String>[code.code, if (country != null) country!.code].join('_');

  @override
  bool operator ==(final Object other) =>
      other is Locale && code == other.code && country == other.country;

  @override
  int get hashCode => Object.hash(code, country);
}
