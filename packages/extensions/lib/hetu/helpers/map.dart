import 'package:hetu_script/hetu_script.dart';

const String mapDefinitions = '''
const MapEachCb: type = fun(key, item) -> any;
external fun eachMap(data: Map, cb: ListEachCb) -> void;
external fun mergeMap(m1: Map, m2: Map) -> Map;
''';

Map<dynamic, dynamic> mergeMap(
  final Map<dynamic, dynamic> m1,
  final Map<dynamic, dynamic> m2,
) =>
    <dynamic, dynamic>{
      ...m1,
      ...m2,
    };

void eachMap(
  final Map<dynamic, dynamic> data,
  final HTFunction fn,
) {
  for (final MapEntry<dynamic, dynamic> x in data.entries) {
    if (fn.call(positionalArgs: <dynamic>[x.key, x.value]) == false) {
      break;
    }
  }
}

List<Map<dynamic, dynamic>> listFromMap(final Map<dynamic, dynamic> data) =>
    data.entries
        .map(
          (final MapEntry<dynamic, dynamic> x) => <dynamic, dynamic>{
            'key': x.key,
            'value': x.value,
          },
        )
        .toList();
