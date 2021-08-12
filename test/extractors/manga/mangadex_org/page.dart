import 'package:yukino_app/core/extractor/manga/mangadex_org.dart';
import 'package:yukino_app/core/extractor/manga/model.dart';
import 'package:yukino_app/core/models/languages.dart';
import '../tester.dart' as tester;

void main() => tester.getPage(
      MangaDexOrg(),
      PageInfo(
        url:
            'https://uploads.mangadex.org/data/29b707a3e4e9f1c228b583c1eaa7ce24/x35-6f76a4fda840ede561ef95a14ecea6968bc2716d9e2142c370c707395c57a99a.jpg',
        locale: LanguageCodes.en,
      ),
    );
