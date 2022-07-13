import 'package:flutter/material.dart';
import '../core/exports.dart';
import 'router/exports.dart';

class BaseApp extends StatelessWidget {
  const BaseApp({
    final Key? key,
  }) : super(key: key);

  @override
  Widget build(final BuildContext context) => MaterialApp.router(
        title: AppMeta.name,
        theme: Themer.defaultThemeData,
        routeInformationParser: routeInformationParser,
        routerDelegate: routerDelegate,
      );
}
