import 'package:yukino_app/core/extractor/manga/mangainn_net.dart';
import 'package:yukino_app/core/extractor/manga/model.dart';
import 'package:yukino_app/core/models/languages.dart';
import '../tester.dart' as tester;

void main() => tester.getPage(
      MangaInnNet(),
      PageInfo(
        url: 'https://www.mangainn.net/mayo-chiki/1/28',
        locale: LanguageCodes.en,
      ),
    );
