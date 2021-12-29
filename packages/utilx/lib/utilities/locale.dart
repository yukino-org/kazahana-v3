import '../generated/locale.g.dart';

export '../generated/locale.g.dart';

class Locale {
  const Locale(this.code, [this.country]);

  factory Locale.fromJson(final Map<String, dynamic> json) => Locale(
        LanguageUtils.nameCodeMap[json['code'] as String]!,
        json['country'] != null
            ? CountryUtils.nameCodeMap[json['country'] as String]
            : null,
      );

  factory Locale.parse(final String locale) {
    final RegExpMatch match = RegExp('([^_]+)(_(.*))?').firstMatch(locale)!;
    final LanguageCodes lang = LanguageUtils.nameCodeMap[match.group(1)!]!;
    final CountryCodes? country = match.group(3) != null
        ? CountryUtils.nameCodeMap[match.group(3)!]
        : null;

    return Locale(lang, country);
  }

  static Locale? tryParse(final String locale) {
    try {
      return Locale.parse(locale);
    } catch (_) {}
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

  Map<String, dynamic> toJson() => <String, dynamic>{
        'code': code.name,
        'country': country?.name,
      };

  String toPrettyString({
    final bool appendCode = false,
  }) =>
      <String>[
        code.language,
        if (country != null) '(${country!.country})',
        if (appendCode) '(${toCodeString()})',
      ].join(' ');

  String toCodeString() =>
      <String>[code.code, if (country != null) country!.code].join('_');

  @override
  String toString() => 'Locale<${toCodeString()}>';

  @override
  bool operator ==(final Object other) =>
      other is Locale && code == other.code && country == other.country;

  @override
  int get hashCode => Object.hash(code, country);
}
