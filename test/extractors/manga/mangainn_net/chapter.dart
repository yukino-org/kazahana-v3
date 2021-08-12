import 'package:yukino_app/core/extractor/manga/mangainn_net.dart';
import 'package:yukino_app/core/extractor/manga/model.dart';
import 'package:yukino_app/core/models/languages.dart';
import '../tester.dart' as tester;

void main() => tester.getChapter(
      MangaInnNet(),
      ChapterInfo(
        title: 'Mayo Chiki!',
        chapter: '1',
        url: 'https://www.mangainn.net/mayo-chiki/1',
        locale: LanguageCodes.en,
      ),
    );
