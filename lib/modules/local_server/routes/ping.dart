import 'package:shelf/shelf.dart';
import '../routes.dart';

final ServerRoute route = ServerRoute(
  'GET',
  'ping',
  (final Request request) => Response(200),
);
