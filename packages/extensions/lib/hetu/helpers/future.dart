import 'dart:async';
import 'package:hetu_script/hetu_script.dart';

const String futureDefinitions = '''
const ResolveFutureCallback: type = fun(err, result); // -> (String?, dynamic)
external fun resolveFuture(future, fn: ResolveFutureCallback);

const ResolveFutureAllCallback: type = fun(err, result); // -> (String?, List<dynamic>)
external fun resolveFutureAll(futures: List, fn: ResolveFutureAllCallback);

const WaitCallback: type = fun();
external fun wait(duration: num, fn: WaitCallback);
''';

Future<dynamic> resolveFuture(
  final FutureOr<dynamic> future,
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

Future<dynamic> wait(
  final int duration,
  final HTFunction fn,
) async {
  await Future<void>.delayed(Duration(milliseconds: duration));
  return await fn.call();
}
