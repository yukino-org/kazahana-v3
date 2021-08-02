enum LanguageCodes { en }

const Map<LanguageCodes, String> languages = {
  LanguageCodes.en: 'English',
};

extension LanguageName on LanguageCodes {
  String get code => toString().split('.').last;
  String get language => languages[this]!;
}

abstract class LanguageSentences {
  LanguageCodes get code;

  String home();
  String search();
  String settings();
  String episodes();
  String episode();
  String noValidSources();
  String prohibitedPage();
  String selectPlugin();
  String searchInPlugin(String plugin);
  String enterToSearch();
  String noResultsFound();
  String failedToGetResults();
  String preferences();
  String landscapeVideoPlayer();
  String landscapeVideoPlayerDetail();
  String theme();
  String systemPreferredTheme();
  String defaultTheme();
  String darkMode();
  String close();
  String chooseTheme();
  String language();
  String chooseLanguage();
  String anime();
  String manga();
  String chapters();
  String volumes();
  String chapter();
  String volume();
  String page();
  String noPagesFound();
  String vol();
  String ch();
  String mangaReaderDirection();
  String horizontal();
  String vertical();
  String mangaReaderSwipeDirection();
  String leftToRight();
  String rightToLeft();
  String mangaReaderMode();
  String list();
  String previous();
  String next();
  String skipIntro();
  String skipIntroDuration();
  String seekDuration();
  String seconds();
  String autoPlay();
  String autoPlayDetail();
  String autoNext();
  String autoNextDetail();
  String speed();
}
