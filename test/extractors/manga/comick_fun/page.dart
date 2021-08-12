import 'package:yukino_app/core/extractor/manga/comick_fun.dart';
import 'package:yukino_app/core/extractor/manga/model.dart';
import 'package:yukino_app/core/models/languages.dart';
import '../tester.dart' as tester;

void main() => tester.getPage(
      ComicKFun(),
      PageInfo(
        url:
            'https://images.weserv.nl/?url=https://lh3.googleusercontent.com/wmEpjDif0mPm4RcVrUEyP6quQverjFBqmRw83-28Q06LB_vS4WWkcP4WxW9NYdOKOZeF-U2evoxRf8L7X3e3HmHSqKKTfPC0omBYM2syu27oDDEp2JIgBlYsLNkjVhr1JDo-vhmxlrg=w1080-h1600',
        locale: LanguageCodes.en,
      ),
    );
