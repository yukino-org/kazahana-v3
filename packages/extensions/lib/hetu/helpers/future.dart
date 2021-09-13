import 'package:hetu_script/hetu_script.dart';

Future<dynamic> resolveFuture(
  final dynamic future,
  final HTFunction fn,
) async {
  dynamic result;
  String? err;

  try {
    result = await future;
  } catch (e) {
    err = e.toString();
  }

  return await fn.call(
    positionalArgs: <dynamic>[err, result],
  );
}
