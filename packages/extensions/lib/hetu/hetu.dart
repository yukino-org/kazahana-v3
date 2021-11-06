import 'package:hetu_script/hetu_script.dart';
import './helpers/helpers.dart' as helpers;

abstract class HetuManager {
  static final String definitions = <String>[
    helpers.cryptoDefinitions,
    helpers.errorDefinitions,
    helpers.futureDefinitions,
    helpers.fuzzyDefinitions,
    helpers.htmlDefinitions,
    helpers.httpDefinitions,
    helpers.jsonDefinitions,
    helpers.languagesDefinitions,
    helpers.listDefinitions,
    helpers.mapDefinitions,
    helpers.qsDefinitions,
    helpers.regexDefinitions,
  ].join('\n');

  static int? _hetuDepLines;

  static Future<Hetu> create() async {
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
        'httpUserAgent': helpers.httpUserAgent,
        'regexMatch': helpers.regexMatch,
        'regexMatchAll': helpers.regexMatchAll,
        'mapList': helpers.mapList,
        'filterList': helpers.filterList,
        'findList': helpers.findList,
        'regexReplaceAll': helpers.regexReplaceAll,
        'regexReplaceFirst': helpers.regexReplaceFirst,
        'resolveFuture': helpers.resolveFuture,
        'throwError': helpers.throwError,
        'ensureURL': helpers.ensureURL,
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

  static String appendDefinitions(final String code) => '''
$definitions

$code
''';

  static void editError(final HTError error) {
    _hetuDepLines ??= RegExp('\n').allMatches(appendDefinitions('')).length - 1;

    if (error.line != null) {
      error.line = error.line! - _hetuDepLines!;
    }
  }
}
