enum LanguageCountries {
  br,
}

extension LanguageCountriesUtils on LanguageCountries {
  String get country => LanguageCountryUtils.codeNameMap[this]!;
}

abstract class LanguageCountryUtils {
  static Map<LanguageCountries, String> codeNameMap =
      <LanguageCountries, String>{
    LanguageCountries.br: 'Brazil',
  };

  static final Map<String, LanguageCountries> nameCodeMap =
      LanguageCountries.values
          .asMap()
          .map(
            (final int k, final LanguageCountries v) =>
                MapEntry<String, LanguageCountries>(
              v.name,
              v,
            ),
          )
          .cast<String, LanguageCountries>();
}
