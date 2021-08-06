import 'package:yukino_app/core/extractor/animes/model.dart';
import 'package:yukino_app/core/extractor/animes/gogoanime_pe.dart';
import 'package:yukino_app/core/models/languages.dart';
import '../tester.dart' as tester;

void main() => tester.getSources(
      GogoAnimePe(),
      EpisodeInfo(
        episode: '1',
        url:
            'https://gogoanime.pe/seishun-buta-yarou-wa-bunny-girl-senpai-no-yume-wo-minai-picture-drama-episode-1',
        locale: LanguageCodes.en,
      ),
    );
