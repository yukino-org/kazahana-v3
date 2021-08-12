import 'package:yukino_app/core/extractor/manga/fanfox_net.dart';
import 'package:yukino_app/core/extractor/manga/model.dart';
import 'package:yukino_app/core/models/languages.dart';
import '../tester.dart' as tester;

void main() => tester.getChapter(
      FanFoxNet(),
      ChapterInfo(
        title: "Butler-kun's Secret",
        volume: '01',
        chapter: '001',
        url: 'https://fanfox.net/manga/mayo_chiki/v01/c001/1.html',
        locale: LanguageCodes.en,
      ),
    );
