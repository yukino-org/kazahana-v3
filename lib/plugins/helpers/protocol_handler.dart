import 'dart:io';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:protocol_registry/protocol_registry.dart' as protocol_registry;
import './assets.dart';
import './screen.dart';
import '../../config.dart';
import '../router.dart';

abstract class ProtocolHandler {
  static const List<String> prohibitedRoutes = <String>[
    RouteNames.initialRoute
  ];

  static Future<void> register() async {
    final protocol_registry.ProtocolScheme scheme =
        protocol_registry.ProtocolScheme(
      scheme: Config.protocol,
      appName: Config.name,
      appPath: Platform.resolvedExecutable,
    );

    if (Platform.isWindows) {
      final protocol_registry.WindowsProtocolRegistry registry =
          protocol_registry.WindowsProtocolRegistry();
      await registry.remove(scheme);
      await registry.add(scheme);
    } else if (Platform.isLinux) {
      final File icon = File(
        p.join(Platform.environment['HOME']!, '.icons/${Config.code}.png'),
      );

      if (!(await icon.exists())) {
        await icon.create(recursive: true);

        final ByteData image = await rootBundle.load(Assets.yukinoIcon);
        await icon.writeAsBytes(
          image.buffer.asUint8List(image.offsetInBytes, image.lengthInBytes),
        );
      }

      final protocol_registry.LinuxProtocolRegistry registry =
          protocol_registry.LinuxProtocolRegistry();
      final String entry = '''
${registry.getEntry(scheme)}
Type=Application
Icon=${Config.code}
'''
          .trim();

      final String path = registry.getDesktopFilePath(scheme);
      final File file = File(path);

      if (!(await file.exists())) {
        await file.create(recursive: true);
      }

      await file.writeAsString(entry);
      await registry.installDesktopFile(
        registry.getDesktopFilePath(scheme),
        scheme,
      );
    }
  }

  static String? parse(final List<String> args) {
    String? url = args.firstOrNull;

    if (url != null) {
      if (url.startsWith(protocolPrefix)) {
        url = url.substring(protocolPrefix.length);
      }

      if (!url.startsWith('/')) {
        url = '/$url';
      }

      return RouteManager.tryGetRouteFromParsedRouteInfo(
                ParsedRouteInfo.fromURI(url),
              ) !=
              null
          ? url
          : null;
    }
  }

  static void handle(final String route) {
    if (!prohibitedRoutes.contains(route)) {
      RouteManager.navigationKey.currentState!.pushNamed(route);
    }

    if (Platform.isWindows || Platform.isLinux) {
      Screen.focus();
    }
  }

  static String get protocolPrefix => '${Config.protocol}://';
}
