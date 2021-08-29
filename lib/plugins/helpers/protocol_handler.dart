import 'dart:io';
import 'package:collection/collection.dart';
import 'package:protocol_registry/protocol_registry.dart' as protocol_registry;
import 'package:window_manager/window_manager.dart';
import '../../config.dart';
import '../router.dart';

abstract class ProtocolHandler {
  static Future<void> register() async {
    final protocol_registry.ProtocolRegistryModel registry =
        protocol_registry.getRegistry();

    final protocol_registry.ProtocolScheme scheme =
        protocol_registry.ProtocolScheme(
      scheme: Config.protocol,
      appName: Config.name,
      appPath: Platform.resolvedExecutable,
    );

    if (Platform.isWindows) {
      await registry.remove(scheme);
      await registry.add(scheme);
    } else if (Platform.isLinux &&
        registry is protocol_registry.LinuxProtocolRegistry) {
      final String entry = '''
${registry.getEntry(scheme)}
Type=Application
'''
          .trim();

      final String path = registry.getDesktopFilePath(scheme);
      final File file = File(path);

      if (await file.exists() == false) {
        await file.create(recursive: true);
      }

      await file.writeAsString(entry);
      await registry.installDesktopFile(
        registry.getDesktopFilePath(scheme),
        scheme,
      );
    }
  }

  static Future<void> handle(final List<String> args) async {
    final String protocolPrefix = '${Config.protocol}://';
    String? url = args.firstOrNull;

    if (url != null) {
      if (url.startsWith(protocolPrefix)) {
        url = url.substring(protocolPrefix.length);
      }

      if (!url.startsWith('/')) {
        url = '/$url';
      }

      final RouteInfo? route = RouteManager.tryGetRouteFromParsedRouteInfo(
        ParsedRouteInfo.fromURI(url),
      );
      if (route != null && RouteManager.navigationKey.currentState != null) {
        RouteManager.navigationKey.currentState!.pushNamed(url);

        if (Platform.isWindows || Platform.isLinux) {
          WindowManager.instance.focus();
        }
      }
    }
  }
}
