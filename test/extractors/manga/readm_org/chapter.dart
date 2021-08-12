import 'package:yukino_app/core/extractor/manga/model.dart';
import 'package:yukino_app/core/extractor/manga/readm_org.dart';
import 'package:yukino_app/core/models/languages.dart';
import '../tester.dart' as tester;

void main() => tester.getChapter(
      ReadMOrg(),
      ChapterInfo(
        chapter: '1',
        url: 'https://readm.org/manga/11798/1/all-pages',
        locale: LanguageCodes.en,
      ),
    );
