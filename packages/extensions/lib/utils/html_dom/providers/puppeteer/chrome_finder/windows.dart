import 'dart:io';

// Refer: https://github.com/gwuhaolin/chrome-finder
abstract class WindowsChromeFinder {
  static final List<String> folders = <String>[
    Platform.environment['LOCALAPPDATA']!,
    Platform.environment['PROGRAMFILES']!,
    Platform.environment['PROGRAMFILES(X86)']!,
  ];

  static const List<String> executables = <String>[
    '\\Google\\Chrome SxS\\Application\\chrome.exe',
    '\\Google\\Chrome\\Application\\chrome.exe',
    '\\chrome-win32\\chrome.exe',
    '\\Chromium\\Application\\chrome.exe',
    '\\Google\\Chrome Beta\\Application\\chrome.exe',
  ];

  static Future<String?> find() async {
    for (final String exe in executables) {
      for (final String folder in folders) {
        final String fullPath = '$folder\\$exe';

        if (await FileSystemEntity.isFile(fullPath)) {
          return fullPath;
        }
      }
    }
  }
}
