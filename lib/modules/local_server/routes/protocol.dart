import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../../helpers/deeplink.dart';
import '../../helpers/protocol_handler.dart';
import '../routes.dart';

final ServerRoute route = ServerRoute(
  'POST',
  'protocol',
  (final Request request) async {
    dynamic args;

    try {
      args = json.decode(await request.readAsString());
    } catch (_) {}

    if (args is List<dynamic> && args.every((final dynamic x) => x is String)) {
      final String? route = ProtocolHandler.fromArgs(args.cast<String>());
      if (route != null) {
        if (Deeplink.hasHandledInitialLink) {
          ProtocolHandler.handle(route);
        } else {
          Deeplink.link = route;
        }

        return Response(200);
      }
    }

    return Response(400, body: 'Bad request');
  },
);
