import 'package:flutter/services.dart';
import 'package:utilx/utilities/utils.dart';
import '../../../../helpers/keyboard.dart';

abstract class KeyboardShortcutsSchemaUtils {
  static Set<LogicalKeyboardKey> getter<T extends Enum>({
    required final T key,
    required final Map<T, Set<LogicalKeyboardKey>?> values,
    required final Map<T, Set<LogicalKeyboardKey>> defaults,
  }) =>
      values[key] ?? defaults[key]!;

  static void setter<T extends Enum>({
    required final T key,
    required final Set<LogicalKeyboardKey>? value,
    required final Map<T, Set<LogicalKeyboardKey>?> values,
  }) {
    values[key] = value;
  }

  static Map<T, Set<LogicalKeyboardKey>?> fromJson<T extends Enum>({
    required final List<T> enumValues,
    required final Map<dynamic, dynamic> json,
  }) {
    final Map<T, Set<LogicalKeyboardKey>?> value =
        <T, Set<LogicalKeyboardKey>?>{};

    for (final MapEntry<dynamic, dynamic> x in json.entries) {
      final T? key = EnumUtils.findOrNull(enumValues, x.key as String);

      if (key != null) {
        value[key] = KeyboardHandler.fromLabels(
          (x.value as List<dynamic>).cast<String>(),
        );
      }
    }

    return value;
  }

  static Map<dynamic, dynamic> toJson<T extends Enum>(
    final Map<T, Set<LogicalKeyboardKey>?> values,
  ) =>
      (<T, Set<LogicalKeyboardKey>?>{
        ...values,
      }..removeWhere(
              (
                final T k,
                final Set<LogicalKeyboardKey>? v,
              ) =>
                  v == null,
            ))
          .map(
        (
          final T k,
          final Set<LogicalKeyboardKey>? v,
        ) =>
            MapEntry<String, dynamic>(k.name, KeyboardHandler.toLabels(v!)),
      );
}
