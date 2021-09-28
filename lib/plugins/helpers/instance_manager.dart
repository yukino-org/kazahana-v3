import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' as path_provider;
import './local_server/routes/ping.dart' as ping_route;
import './local_server/routes/protocol.dart' as protocol_route;
import './local_server/server.dart';
import './logger.dart';
import './utils/string.dart';
import '../../config.dart';

class InstanceInfo {
  InstanceInfo({
    required final this.serverURL,
    required final this.createdAt,
  });

  factory InstanceInfo.fromJson(final Map<dynamic, dynamic> json) =>
      InstanceInfo(
        serverURL: json['server_url']! as String,
        createdAt: json['created_at']! as int,
      );

  final String serverURL;
  final int createdAt;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'server_url': serverURL,
        'created_at': createdAt,
      };
}

abstract class InstanceManager {
  static Future<InstanceInfo?> check() async {
    final File file = File(await _getPath());

    if (await file.exists()) {
      final String content = await file.readAsString();

      InstanceInfo? instance;
      try {
        instance = InstanceInfo.fromJson(
          json.decode(utf8.decode(base64.decode(content)))
              as Map<dynamic, dynamic>,
        );
      } catch (err) {
        rethrow;
      }

      try {
        final http.Response res = await http.get(
          Uri.parse('${instance.serverURL}/${ping_route.route.route}'),
        );
        if (res.statusCode == 200) {
          return instance;
        }
      } catch (_) {}
    }
  }

  static Future<InstanceInfo> register() async {
    final File file = File(await _getPath());
    await file.create(recursive: true);

    final InstanceInfo instance = InstanceInfo(
      serverURL: LocalServer.baseURL,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    await file.writeAsString(
      base64.encode(utf8.encode(json.encode(instance.toJson()))),
    );

    Logger.of(InstanceManager)
        .info('Finished ${StringUtils.type(InstanceManager.register)}');

    return instance;
  }

  static Future<void> sendArguments(
    final InstanceInfo info,
    final List<String> args,
  ) async {
    final http.Response res = await http.post(
      Uri.parse('${info.serverURL}/${protocol_route.route.route}'),
      body: json.encode(args),
      headers: <String, String>{
        'Content-Type': ContentType.json.value,
      },
    );
    if (<int>[200, 400].contains(res.statusCode)) {
      Logger.of(InstanceManager).info(
        'Finished ${StringUtils.type(InstanceManager.sendArguments)}',
      );
    }
  }

  static Future<String> _getPath() async {
    final Directory documentsDir =
        await path_provider.getApplicationDocumentsDirectory();
    return p.join(documentsDir.path, Config.code, '.instance');
  }
}
