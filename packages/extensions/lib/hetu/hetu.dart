import 'dart:convert';
import 'package:hetu_script/hetu_script.dart';
import './helpers/crypto.dart' as helpers;
import './helpers/fetch.dart' as helpers;
import './helpers/future.dart' as helpers;
import './helpers/fuzzy.dart' as helpers;
import './helpers/html.dart' as helpers;
import './helpers/list.dart' as helpers;
import './helpers/map.dart' as helpers;
import './helpers/regexp.dart' as helpers;
import './helpers/string.dart' as helpers;
import './helpers/throw_err.dart' as helpers;
import '../utils/http.dart';

const String hetuExternals = '''
// Http utilities - start
external fun fetch(data: Map);
external fun httpUserAgent() -> str;
external fun ensureURL(url: str) -> str;
// Http utilities - end


// Crypto - start
external fun decryptCryptoJsAES(salted: str, decrypter: str, length: num) -> str;
// Crypto - end


// Fuzzy Search - start
const FuzzySearcher: type = fun(terms: str, limit: num) -> List<Map>;
external fun createFuzzy(data: List<Map>, keys: List<Map>) -> FuzzySearcher;
// Fuzzy Search - end


// Html Parser - start
external class HtmlElement {
  const classes: List<str>;
  const id: str?;
  const text: str?;
  const innerHtml: str;
  const outerHtml: str;
  const attributes: Map<str>;
  fun querySelector(selector: str) -> HtmlElement?;
  fun querySelectorAll(selector: str) -> List<HtmlElement>;
}
external fun parseHtml(html: str) -> HtmlElement;
// Html Parser - end


// JSON utlities - start
external fun jsonEncode(data) -> str;
external fun jsonDecode(data: str);
// JSON utlities - end


// RegExp utlities - start
external class RegExpMatchResult {
    const input: str;
    fun group(group: num) -> str?;
}
external fun regexMatch(regex: str, text: str) -> RegExpMatchResult?;
external fun regexMatchAll(regex: str, text: str) -> List<RegExpMatchResult>;
// RegExp utlities - end


// List utlities - start
const ListMapper: type = fun(i: num, item: any) -> any;
external fun mapList(data: List<any>, mapper: ListMapper) -> str;

const ListFilterer: type = fun(i: num, item: any) -> bool;
external fun filterList(data: List<any>, filterer: ListFilterer) -> List<any>;

const ListEachCb: type = fun(i: num, item: any) -> any;
external fun eachList(data: List<any>, cb: ListEachCb) -> void;

external fun findList(data: List<any>, filterer: ListFilterer) -> any?;
external fun mergeList(m1: List<any>, m2: List<any>) -> List<any>;
external fun rangeList(a: int, b: int) -> List<int>;
// List utlities - end


// String utlities - start
external fun regexReplaceAll(data: str, from: str, to: str) -> str;
external fun regexReplaceFirst(data: str, from: str, to: str) -> str;
// String utlities - end


// Future utlities - start
const ResolveFutureCallback: type = fun(err: str?, result);
external fun resolveFuture(future, fn: ResolveFutureCallback);
// Future utlities - end


// Map utlities - start
const MapEachCb: type = fun(key: any, item: any) -> any;
external fun eachMap(data: Map, cb: ListEachCb) -> void;
external fun mergeMap(m1: Map, m2: Map) -> Map;
// Map utlities - end


// Other utlities - start
external fun throwError(err: str) -> void;
// Other utlities - end
''';

String appendHetuExternals(final String code) => '''
$hetuExternals

$code
''';

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
      'jsonEncode': (final dynamic data) => jsonEncode(data),
      'jsonDecode': (final String data) => jsonDecode(data),
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
      'sliceString': helpers.sliceString,
    },
  );

  return hetu;
}
