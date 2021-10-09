import 'package:hetu_script/hetu_script.dart';

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
  data.forEach(
    (final dynamic k, final dynamic v) {
      fn.call(positionalArgs: <dynamic>[k, v]);
    },
  );
}
