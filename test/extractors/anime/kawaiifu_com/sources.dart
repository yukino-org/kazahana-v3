import 'package:yukino_app/core/extractor/animes/kawaiifu_com.dart';
import 'package:yukino_app/core/extractor/animes/model.dart';
import 'package:yukino_app/core/models/languages.dart';
import '../tester.dart' as tester;

void main() => tester.getSources(
      KawaiifuCom(),
      EpisodeInfo(
        episode: '6',
        url:
            'https://domdom.stream/anime/season/summer-2021/girlfriend-girlfriend-kanojo-mo-kanojo-episode?ep=6',
        locale: LanguageCodes.en,
      ),
    );
