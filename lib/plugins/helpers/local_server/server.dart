import 'dart:async';
import 'dart:io';
import 'package:collection/collection.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import './routes.dart';

abstract class LocalServer {
  static bool ready = false;
  static HttpServer? server;

  static const String protocol = 'http';
  static const String host = 'localhost';
  static int port = 0;

  static FutureOr<Response> _handler(final Request request) {
    final ServerRoute? route = routes.firstWhereOrNull(
      (final ServerRoute x) =>
          x.method == request.method && x.route == request.url.path,
    );
    if (route == null) {
      return Response(404, body: 'Unknown route');
    }

    try {
      return route.handler(request);
    } catch (e) {
      return Response.internalServerError(
        body: 'Unknown error: ${e.toString()}',
      );
    }
  }

  static Future<void> initialize() async {
    server = await shelf_io.serve(_handler, host, port);
    port = server!.port;
  }

  static String get baseURL => '$protocol://$host:$port';
}
