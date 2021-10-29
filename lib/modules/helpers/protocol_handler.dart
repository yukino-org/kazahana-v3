import 'dart:io';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:protocol_registry/protocol_registry.dart';
import './assets.dart';
import './screen.dart';
import '../../config/app.dart';
import '../../ui/router.dart';

abstract class ProtocolHandler {
  static const List<String> prohibitedRoutes = <String>[
    RouteNames.initialRoute
  ];

  static Future<void> register() async {
    final ProtocolScheme scheme = ProtocolScheme(
      scheme: Config.protocol,
      appName: Config.name,
      appPath: Platform.resolvedExecutable,
    );

    if (Platform.isWindows) {
      final WindowsProtocolRegistry registry = WindowsProtocolRegistry();
      await registry.remove(scheme);
      await registry.add(scheme);
    } else if (Platform.isLinux) {
      final File icon = File(
        path.join(Platform.environment['HOME']!, '.icons/${Config.code}.png'),
      );

      if (!(await icon.exists())) {
        await icon.create(recursive: true);

        final ByteData image = await rootBundle.load(Assets.yukinoIcon);
        await icon.writeAsBytes(
          image.buffer.asUint8List(image.offsetInBytes, image.lengthInBytes),
        );
      }

      final LinuxProtocolRegistry registry = LinuxProtocolRegistry();
      final String entry = '''
${registry.getEntry(scheme)}
Type=Application
Icon=${Config.code}
'''
          .trim();

      final String filePath = registry.getDesktopFilePath(scheme);
      final File file = File(filePath);

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

  static String? fromArgs(final List<String> args) {
    final String? url = args.firstOrNull;
    return url != null ? parse(url) : null;
  }

  static String? parse(final String _url) {
    String url = _url;

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

  static void handle(final String route) {
    if (!prohibitedRoutes.contains(route)) {
      final String? link = ProtocolHandler.parse(route);
      if (link != null) {
        RouteManager.navigationKey.currentState!.pushNamed(link);
        Screen.focus();
      }
    }
  }

  static String get protocolPrefix => '${Config.protocol}://';
}
