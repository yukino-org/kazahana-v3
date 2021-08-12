import 'package:yukino_app/core/extractor/manga/manganato_com.dart';
import 'package:yukino_app/core/extractor/manga/model.dart';
import 'package:yukino_app/core/models/languages.dart';
import '../tester.dart' as tester;

void main() => tester.getPage(
      MangaNatoCom(),
      PageInfo(
        url:
            'https://s51.mkklcdnv6tempv2.com/mangakakalot/y1/yahari_4koma_demo_ore_no_seishun_love_come_wa_machigatteiru/vol1_chapter_1/15.jpg',
        locale: LanguageCodes.en,
      ),
    );
