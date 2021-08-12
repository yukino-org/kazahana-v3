import 'package:yukino_app/core/extractor/manga/fanfox_net.dart';
import '../tester.dart' as tester;

void main() => tester.getInfo(
      FanFoxNet(),
      'https://fanfox.net/manga/mayo_chiki/',
    );
