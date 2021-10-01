import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' as path_provider;
import '../../config.dart';

class Logger {
  Logger._(this.name);

  factory Logger.of(final String name) {
    if (!instances.containsKey(name)) {
      instances[name] = Logger._(name);
    }

    return instances[name]!;
  }

  final String name;

  void info(final String msg) {
    final String _msg = '[$time INFO] $name: $msg';
    _write(_msg);
  }

  void warn(final String msg) {
    final String _msg = '[$time WARN] $name: $msg';
    _write(_msg);
  }

  void error(final String msg, [final StackTrace? trace]) {
    final String _msg = '[$time ERR!] $name: $msg';
    _write(_msg);

    trace.toString().split('\n').forEach((final String x) {
      _write('  $x');
    });
  }

  static late String path;
  static late IOSink file;
  static final Map<String, Logger> instances = <String, Logger>{};

  static bool ready = false;

  static Future<void> initialize() async {
    final Directory tmpPath = await path_provider.getTemporaryDirectory();
    final DateTime time = DateTime.now();
    path = p.join(
      tmpPath.path,
      Config.code,
      'debug ${time.day}-${time.month}-${time.year}.log',
    );

    final File file = File(path);
    if (!(await file.exists())) {
      await file.create(recursive: true);
    }

    Logger.file = file.openWrite(
      mode: FileMode.append,
    );

    ready = true;
  }

  static void _write(final String msg) {
    debugPrint(msg);
    file.write('$msg\n');
  }

  static String get time => DateTime.now().toIso8601String();
}
