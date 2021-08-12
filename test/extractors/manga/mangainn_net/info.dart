import 'package:yukino_app/core/extractor/manga/mangainn_net.dart';
import '../tester.dart' as tester;

void main() => tester.getInfo(
      MangaInnNet(),
      'https://www.mangainn.net/mayo-chiki',
    );
