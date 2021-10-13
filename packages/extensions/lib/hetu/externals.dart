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
external fun regexReplaceAll(data: str, from: str, to: str) -> str;
external fun regexReplaceFirst(data: str, from: str, to: str) -> str;
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
external fun rangeList(a: num, b: num) -> List<int>;
external fun flattenList(data: List, level: num) -> List;
external fun deepFlattenList(data: List) -> List;
// List utlities - end


// Future utlities - start
const ResolveFutureCallback: type = fun(err: str?, result);
external fun resolveFuture(future, fn: ResolveFutureCallback);

const ResolveFutureAllCallback: type = fun(err: str?, result: List);
external fun resolveFutureAll(futures: List, fn: ResolveFutureAllCallback);

const WaitCallback: type = fun();
external fun wait(duration: num, fn: WaitCallback);
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
