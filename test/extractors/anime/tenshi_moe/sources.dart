import 'package:yukino_app/core/extractor/animes/model.dart';
import 'package:yukino_app/core/extractor/animes/tenshi_moe.dart';
import 'package:yukino_app/core/models/languages.dart';
import '../tester.dart' as tester;

void main() => tester.getSources(
      TenshiMoe(),
      EpisodeInfo(
        episode: '220',
        url: 'https://tenshi.moe/anime/kjfrhu3s/220',
        locale: LanguageCodes.en,
      ),
    );
