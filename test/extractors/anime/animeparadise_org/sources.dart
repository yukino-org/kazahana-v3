import 'package:yukino_app/core/extractor/animes/animeparadise_org.dart';
import 'package:yukino_app/core/extractor/animes/model.dart';
import 'package:yukino_app/core/models/languages.dart';
import '../tester.dart' as tester;

void main() => tester.getSources(
      AnimePradiseOrg(),
      EpisodeInfo(
        episode: '1',
        url: 'https://animeparadise.org/watch.php?s=54&ep=1',
        locale: LanguageCodes.en,
      ),
    );
