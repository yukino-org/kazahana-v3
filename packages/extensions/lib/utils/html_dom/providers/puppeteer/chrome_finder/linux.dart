import 'dart:io';

class _ChromeConfig {
  const _ChromeConfig(this.path, this.priority);

  final String path;
  final int priority;
}

// Refer: https://github.com/gwuhaolin/chrome-finder
abstract class LinuxChromeFinder {
  static const List<String> folders = <String>[
    '/usr/bin',
    '/usr/local/bin',
    '/usr/sbin',
    '/usr/local/sbin',
    '/opt/bin',
    '/usr/bin/X11',
    '/usr/X11R6/bin',
  ];

  static const List<_ChromeConfig> executables = <_ChromeConfig>[
    _ChromeConfig('chromium/chrome', 47),
    _ChromeConfig('chromium-browser', 48),
    _ChromeConfig('google-chrome', 49),
    _ChromeConfig('google-chrome-stable', 50),
    _ChromeConfig('chromium', 52),
  ];

  static Future<String?> find() async {
    final List<_ChromeConfig> installed = <_ChromeConfig>[];

    for (final _ChromeConfig config in executables) {
      for (final String folder in folders) {
        final String fullPath = '$folder/${config.path}';

        if (await FileSystemEntity.isFile(fullPath)) {
          installed.add(_ChromeConfig(fullPath, config.priority));
        } else {
          final ProcessResult result =
              await Process.run('which', <String>[config.path]);
          final String? foundPath = RegExp(r'([^\n])+')
              .firstMatch(result.stdout.toString())
              ?.group(1);

          if (foundPath != null && await FileSystemEntity.isFile(foundPath)) {
            installed.add(_ChromeConfig(fullPath, config.priority));
          }
        }
      }
    }

    installed.sort(
      (final _ChromeConfig a, final _ChromeConfig b) => b.priority - a.priority,
    );

    return installed.isNotEmpty ? installed[0].path : null;
  }
}
