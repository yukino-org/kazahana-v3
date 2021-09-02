import 'dart:io';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' as path_provider;
import '../../config.dart';

abstract class Logger {
  static late String path;
  static late RandomAccessFile file;

  static bool ready = false;

  static Future<void> initialize() async {
    final Directory tmpPath = await path_provider.getTemporaryDirectory();
    path = p.join(tmpPath.path, Config.code, 'debug.log');
    final File file = File(path);
    if (await file.exists() == false) {
      await file.create(recursive: true);
    }

    Logger.file = await file.open(
      mode: FileMode.append,
    );

    ready = true;
  }

  static void _printIfDebug(final String msg) {
    debugPrint(msg);
  }

  static Future<void> info(final String msg) async {
    final String _msg = '[$time INFO] $msg';
    _printIfDebug(_msg);
    await file.writeString(_msg);
  }

  static Future<void> warn(final String msg) async {
    final String _msg = '[$time WARN] $msg';
    _printIfDebug(_msg);
    await file.writeString(_msg);
  }

  static Future<void> error(final String msg) async {
    final String _msg = '[$time ERR!] $msg';
    _printIfDebug(_msg);
    await file.writeString(_msg);
  }

  static String get time => DateTime.now().toUtc().toString().split('.')[0];
}
