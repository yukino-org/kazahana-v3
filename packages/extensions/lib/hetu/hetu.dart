import 'package:hetu_script/hetu_script.dart';
import './externals.dart';
import './helpers/crypto.dart' as helpers;
import './helpers/fetch.dart' as helpers;
import './helpers/future.dart' as helpers;
import './helpers/fuzzy.dart' as helpers;
import './helpers/html.dart' as helpers;
import './helpers/json.dart' as helpers;
import './helpers/languages.dart' as helpers;
import './helpers/list.dart' as helpers;
import './helpers/map.dart' as helpers;
import './helpers/qs.dart' as helpers;
import './helpers/regexp.dart' as helpers;
import './helpers/throw_err.dart' as helpers;
import '../utils/http.dart';

export './externals.dart';

Future<Hetu> createHetu() async {
  final Hetu hetu = Hetu();

  await hetu.init(
    externalClasses: <HTExternalClass>[
      helpers.HtmlElementClassBinding(),
      helpers.RegExpMatchResultClassBinding(),
    ],
    externalFunctions: <String, Function>{
      'decryptCryptoJsAES': helpers.decryptCryptoJsAES,
      'fetch': helpers.fetch,
      'createFuzzy': helpers.createFuzzy,
      'parseHtml': helpers.parseHtml,
      'jsonEncode': helpers.jsonEncode,
      'jsonDecode': helpers.jsonDecode,
      'httpUserAgent': () => HttpUtils.userAgent,
      'regexMatch': helpers.regexMatch,
      'regexMatchAll': helpers.regexMatchAll,
      'mapList': helpers.mapList,
      'filterList': helpers.filterList,
      'findList': helpers.findList,
      'regexReplaceAll': helpers.regexReplaceAll,
      'regexReplaceFirst': helpers.regexReplaceFirst,
      'resolveFuture': helpers.resolveFuture,
      'throwError': helpers.throwError,
      'ensureURL': HttpUtils.ensureURL,
      'eachList': helpers.eachList,
      'eachMap': helpers.eachMap,
      'mergeMap': helpers.mergeMap,
      'mergeList': helpers.mergeList,
      'rangeList': helpers.rangeList,
      'resolveFutureAll': helpers.resolveFutureAll,
      'flattenList': helpers.flattenList,
      'deepFlattenList': helpers.deepFlattenList,
      'wait': helpers.wait,
      'qsEncode': helpers.qsEncode,
      'qsDecode': helpers.qsDecode,
      'allLanguages': helpers.allLanguages,
      'isValidLanguages': helpers.isValidLanguages,
    },
  );

  return hetu;
}

int? _hetuDepLines;
void editHetuError(final HTError error) {
  _hetuDepLines ??= RegExp('\n').allMatches(appendHetuExternals('')).length - 1;

  if (error.line != null) {
    error.line = error.line! - _hetuDepLines!;
  }
}
