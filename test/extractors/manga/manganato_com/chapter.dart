import 'package:yukino_app/core/extractor/manga/manganato_com.dart';
import 'package:yukino_app/core/extractor/manga/model.dart';
import 'package:yukino_app/core/models/languages.dart';
import '../tester.dart' as tester;

void main() => tester.getChapter(
      MangaNatoCom(),
      ChapterInfo(
        volume: '1',
        chapter: '1',
        url: 'https://readmanganato.com/manga-le962587/chapter-1',
        locale: LanguageCodes.en,
      ),
    );
