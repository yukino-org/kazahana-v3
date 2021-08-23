import 'dart:io';
import 'package:path/path.dart' as p;
import '../../config.dart';

abstract class ProtocolHandler {
  static Future<bool> _registerLinux() async {
    final String content = '''
[Desktop Entry]
Name=${Config.name}
Exec=${Platform.resolvedExecutable} %u
Type=Application
Terminal=false
MimeType=x-scheme-handler/${Config.protocol};
'''
        .trim();

    final String path = p.join(
      Platform.environment['HOME']!,
      '.local',
      'share',
      'applications',
      '${Config.protocol}.desktop',
    );

    final File file = File(path);
    await file.create(recursive: true);
    await file.writeAsString(content);

    await Process.run(
      'xdg-mime',
      <String>['default', path, 'x-scheme-handler/${Config.protocol}'],
    );

    return true;
  }

  static Future<bool> register() async {
    if (Platform.isLinux) {
      return _registerLinux();
    }

    return false;
  }

  static Future<void> handle(final List<String> args) async {}
}
