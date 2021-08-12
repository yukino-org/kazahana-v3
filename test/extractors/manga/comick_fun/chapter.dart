import 'package:yukino_app/core/extractor/manga/comick_fun.dart';
import 'package:yukino_app/core/extractor/manga/model.dart';
import 'package:yukino_app/core/models/languages.dart';
import '../tester.dart' as tester;

void main() => tester.getChapter(
      ComicKFun(),
      ChapterInfo(
        title: 'Reborn',
        volume: '1',
        chapter: '1',
        url: 'https://comick.fun/comic/tokyo-revengers/vl3VM-chapter-1-en',
        locale: LanguageCodes.en,
        other: ComicKFunChapterMeta(
          hid: 'vl3VM',
        ).toJson(),
      ),
    );
