import 'dart:async';
import 'package:flutter/material.dart';
import 'package:utilx/utilities/utils.dart';
import './modules/app/lifecycle.dart';
import './modules/helpers/logger.dart';
import './ui/base.dart';

Future<void> main(final List<String> args) async {
  try {
    await AppLifecycle.preinitialize(args);
    Logger.of('main').info('Completed "preinitialize"');
  } catch (err, trace) {
    Logger.of('main').error(
      '"preinitialize" failed: $err',
      trace,
    );
    AppLifecycle.lastError = ErrorInfo(err, trace);
  }

  Logger.of('main').info('Starting "MainApp"');

  runZonedGuarded(() async {
    FlutterError.onError = (final FlutterErrorDetails details) {
      FlutterError.presentError(details);
      Logger.of('main').error(
        'Uncaught error: ${details.exceptionAsString()}',
        details.stack,
      );
    };

    runApp(const MainApp());
  }, (final Object error, final StackTrace stack) {
    Logger.of('main').error(
      'Uncaught error: ${error.toString()}',
      stack,
    );
  });
}
