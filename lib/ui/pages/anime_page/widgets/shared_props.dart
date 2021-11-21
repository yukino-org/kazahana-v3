import 'package:extensions/extensions.dart';
import 'package:utilx/utilities/locale.dart';
import '../../../../modules/utils/utils.dart';

enum Pages {
  home,
  player,
}

extension AnimeInfoUtils on AnimeInfo {
  List<EpisodeInfo> get sortedEpisodes => ListUtils.tryArrange(
        episodes,
        (final EpisodeInfo x) => x.episode,
      );
}

class SharedProps {
  SharedProps({
    required final this.setEpisode,
    required final this.goToPage,
  });

  AnimeExtractor? extractor;
  AnimeInfo? info;
  EpisodeInfo? episode;
  int? currentEpisodeIndex;
  Locale? locale;

  void Function(int?) setEpisode;
  Future<void> Function(Pages) goToPage;
}
