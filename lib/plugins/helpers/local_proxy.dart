import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import './querystring.dart';

abstract class LocalProxy {
  static bool ready = false;
  static HttpServer? server;

  static const String protocol = 'http';
  static const String host = 'localhost';
  static int port = 0;

  static Future<void> initialize() async {
    server = await shelf_io.serve(handler, host, port);
    port = server!.port;
  }

  static FutureOr<Response> handler(final Request request) async {
    final Uri? uri = Uri.tryParse(Uri.decodeComponent(request.url.path));
    if (uri == null) {
      return Response(400, body: 'Invalid path url');
    }

    try {
      final http.StreamedRequest req =
          http.StreamedRequest(request.method, uri);

      req
        ..headers.addAll(request.url.queryParameters)
        ..headers['Host'] = uri.authority;

      unawaited(
        request
            .read()
            .forEach(req.sink.add)
            .catchError(req.sink.addError)
            .whenComplete(req.sink.close),
      );

      final http.StreamedResponse res = await req.send();

      final List<String> forbiddenHeaders = <String>['transfer-encoding'];
      final Map<String, String> headers = <String, String>{};
      res.headers.forEach((final String k, final String v) {
        if (k == 'content-encoding' && v == 'gzip') {
          forbiddenHeaders
              .addAll(<String>['content-encoding', 'content-length']);
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
  }

  static String get baseURL => '$protocol://$host:$port';

  static String constructProxiedURL(
    final String url, [
    final Map<String, String> headers = const <String, String>{},
  ]) {
    final String qs = QueryString.stringify(headers);
    return '$baseURL/${Uri.encodeComponent(url)}?$qs';
  }
}
