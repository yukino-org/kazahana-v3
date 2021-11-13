import 'dart:io';
import './linux.dart';
import './windows.dart';

abstract class ChromeFinder {
  static Future<String?> find() async {
    if (Platform.isWindows) {
      return WindowsChromeFinder.find();
    }

    if (Platform.isLinux) {
      return LinuxChromeFinder.find();
    }
  }
}
