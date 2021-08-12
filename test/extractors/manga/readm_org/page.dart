import 'package:yukino_app/core/extractor/manga/model.dart';
import 'package:yukino_app/core/extractor/manga/readm_org.dart';
import 'package:yukino_app/core/models/languages.dart';
import '../tester.dart' as tester;

void main() => tester.getPage(
      ReadMOrg(),
      PageInfo(
        url: 'https://readm.org/uploads/chapter_files/11798/0/p_00028.jpg',
        locale: LanguageCodes.en,
      ),
    );
