import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shelf/shelf.dart';
import '../../querystring.dart';
import '../routes.dart';
import '../server.dart';

final ServerRoute route =
    ServerRoute('GET', 'proxy', (final Request request) async {
  try {
    final Uri? uri = request.url.queryParameters['url'] != null
        ? Uri.tryParse(Uri.decodeComponent(request.url.queryParameters['url']!))
        : null;
    if (uri == null) {
      return Response(400, body: 'Missing query: url');
    }

    final http.StreamedRequest req = http.StreamedRequest(request.method, uri);

    req
      ..headers.addAll(request.url.queryParameters)
      ..headers.addAll(request.headers)
      ..headers['Host'] = uri.authority;

    unawaited(
      request
          .read()
          .forEach(req.sink.add)
          .catchError(req.sink.addError)
          .whenComplete(req.sink.close),
    );

    final http.StreamedResponse res = await req.send();

    final List<String> forbiddenHeaders = <String>['url', 'transfer-encoding'];
    final Map<String, String> headers = <String, String>{};
    res.headers.forEach((final String k, final String v) {
      if (k == 'content-encoding' && v == 'gzip') {
        forbiddenHeaders.addAll(<String>['content-encoding', 'content-length']);
      }

      if (!forbiddenHeaders.contains(k)) {
        headers[k] = v;
      }
    });

    return Response(res.statusCode, body: res.stream, headers: headers);
  } catch (e) {
    return Response.internalServerError(
      body: 'Unknown error: ${e.toString()}',
    );
  }
});

String getProxiedURL(
  final String url, [
  final Map<String, String> headers = const <String, String>{},
]) {
  final String qs = QueryString.stringify(<String, String>{
    'url': Uri.encodeComponent(url),
    ...headers,
  });
  return '${LocalServer.baseURL}/${route.route}?$qs';
}
