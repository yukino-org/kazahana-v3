import 'package:flutter/services.dart';
import '../../../../helpers/keyboard.dart';

Set<LogicalKeyboardKey> pickNonNullKeySet(
  final Set<LogicalKeyboardKey>? f,
  final Set<LogicalKeyboardKey> d,
) =>
    f?.isNotEmpty ?? false ? f! : d;

Set<LogicalKeyboardKey>? pickKeySetFromJson(
  final Map<dynamic, dynamic> json,
  final String key,
) =>
    json[key] != null
        ? KeyboardHandler.fromLabels(
            (json[key] as List<dynamic>).cast<String>(),
          )
        : null;
