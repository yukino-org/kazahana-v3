import 'package:hetu_script/hetu_script.dart';

Future<dynamic> resolveFuture(
  final Future<dynamic> future,
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

Future<dynamic> resolveFutureAll(
  final List<dynamic> futures,
  final HTFunction fn,
) async {
  List<dynamic>? result;
  String? err;

  try {
    result = await Future.wait(futures.cast<Future<dynamic>>())
        .timeout(const Duration(seconds: 30));
  } catch (e) {
    err = e.toString();
  }

  return await fn.call(
    positionalArgs: <dynamic>[err, result],
  );
}
