import 'package:yukino_app/core/extractor/animes/model.dart';
import 'package:yukino_app/core/extractor/animes/twist_moe.dart';
import 'package:yukino_app/plugins/translator/model.dart';
import '../tester.dart' as tester;

void main() => tester.getSources(
      TwistMoe(),
      EpisodeInfo(
        episode: '12',
        url: 'https://twist.moe/a/manyuu-hikenchou/12',
        locale: LanguageCodes.en,
      ),
    );
