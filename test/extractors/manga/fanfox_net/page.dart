import 'package:yukino_app/core/extractor/manga/fanfox_net.dart';
import 'package:yukino_app/core/extractor/manga/model.dart';
import 'package:yukino_app/core/models/languages.dart';
import '../tester.dart' as tester;

void main() => tester.getPage(
      FanFoxNet(),
      PageInfo(
        url: 'https://m.fanfox.net/manga/mayo_chiki/v01/c001/28.html',
        locale: LanguageCodes.en,
      ),
    );
