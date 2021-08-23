import 'package:shelf/shelf.dart';
import './routes/ping.dart' as ping_route;
import './routes/protocol.dart' as protocol_route;
import './routes/proxy.dart' as proxy_route;

class ServerRoute {
  ServerRoute(this.method, this.route, this.handler);

  final String method;
  final String route;
  final Handler handler;
}

final List<ServerRoute> routes = <ServerRoute>[
  ping_route.route,
  protocol_route.route,
  proxy_route.route,
];
