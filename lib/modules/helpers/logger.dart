import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import '../../config/paths.dart';

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

  static late String filePath;
  static late IOSink file;
  static final Map<String, Logger> instances = <String, Logger>{};

  static bool ready = false;

  static Future<void> initialize() async {
    final DateTime time = DateTime.now();
    filePath = path.join(
      PathDirs.temp,
      'debug ${time.day}-${time.month}-${time.year}.log',
    );

    final File file = File(filePath);
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

  static Future<String> read() => File(filePath).readAsString();

  static String get time => DateTime.now().toIso8601String();
}
