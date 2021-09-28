import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' as path_provider;
import './utils/string.dart';
import '../../config.dart';

class Logger {
  Logger._(this.name);

  factory Logger.of(final dynamic data) {
    final String name = StringUtils.type(data, quotes: false);

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
  static late RandomAccessFile file;
  static const Duration _writeDuration = Duration(seconds: 10);
  static final List<String> _pending = <String>[];
  static final Map<String, Logger> instances = <String, Logger>{};

  static bool ready = false;

  static Future<void> initialize() async {
    final Directory tmpPath = await path_provider.getTemporaryDirectory();
    final DateTime time = DateTime.now();
    path = p.join(
      tmpPath.path,
      Config.code,
      'debug ${time.day}-${time.month}-${time.year} ${time.hour}-${time.minute}-${time.second}.log',
    );

    final File file = File(path);
    if (!(await file.exists())) {
      await file.create(recursive: true);
    }

    Logger.file = await file.open(
      mode: FileMode.append,
    );

    Timer.periodic(_writeDuration, (final Timer timer) {
      _writePending();
    });

    ready = true;
  }

  static void _write(final String msg) {
    debugPrint(msg);
    _pending.add(msg);
  }

  static Future<void> _writePending() async {
    if (_pending.isNotEmpty) {
      file.writeString(_pending.join('\n'));
      _pending.clear();
    }
  }

  static String get time => DateTime.now().toUtc().toString().split('.')[0];
}
