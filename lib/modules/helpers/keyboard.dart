import 'package:flutter/services.dart';

class KeyboardKeyHandler {
  const KeyboardKeyHandler(this.keys, this.handler);

  final Set<LogicalKeyboardKey> keys;
  final void Function(RawKeyEvent) handler;

  bool isPressed(final Set<LogicalKeyboardKey> keys) =>
      this.keys.length == keys.length &&
      this.keys.every((final LogicalKeyboardKey x) => keys.contains(x));
}

class KeyboardHandler {
  const KeyboardHandler({
    final this.onKeyDown = const <KeyboardKeyHandler>[],
  });

  final List<KeyboardKeyHandler> onKeyDown;

  KeyboardKeyHandler? findHandler(
    final List<KeyboardKeyHandler> handlers,
    final Set<LogicalKeyboardKey> keys,
  ) {
    for (final KeyboardKeyHandler x in handlers) {
      if (x.isPressed(keys)) {
        return x;
      }
    }
  }

  void onRawKeyEvent(
    final RawKeyEvent event, {
    final bool normalizeKeys = true,
  }) {
    final Set<LogicalKeyboardKey> keysPressed = normalizeKeys
        ? KeyboardHandler.normalizeKeys(RawKeyboard.instance.keysPressed)
        : RawKeyboard.instance.keysPressed;

    if (event is RawKeyDownEvent) {
      findHandler(onKeyDown, keysPressed)?.handler(event);
    }
  }

  static final Map<LogicalKeyboardKey, LogicalKeyboardKey> normalized =
      <LogicalKeyboardKey, LogicalKeyboardKey>{
    LogicalKeyboardKey.altLeft: LogicalKeyboardKey.alt,
    LogicalKeyboardKey.altRight: LogicalKeyboardKey.alt,
    LogicalKeyboardKey.controlLeft: LogicalKeyboardKey.control,
    LogicalKeyboardKey.controlRight: LogicalKeyboardKey.control,
    LogicalKeyboardKey.shiftLeft: LogicalKeyboardKey.shift,
    LogicalKeyboardKey.shiftRight: LogicalKeyboardKey.shift,
  };

  static final Map<LogicalKeyboardKey, String> readables =
      <LogicalKeyboardKey, String>{
    LogicalKeyboardKey.space: 'Space',
  };

  static final Map<String, LogicalKeyboardKey> nameCodeMap =
      Map<String, LogicalKeyboardKey>.fromEntries(
    LogicalKeyboardKey.knownLogicalKeys.map(
      (final LogicalKeyboardKey x) =>
          MapEntry<String, LogicalKeyboardKey>(x.keyLabel, x),
    ),
  )..removeWhere(
          (final String key, final LogicalKeyboardKey value) => key.isEmpty,
        );

  static LogicalKeyboardKey normalizeKey(final LogicalKeyboardKey key) =>
      normalized[key] ?? key;

  static Set<LogicalKeyboardKey> normalizeKeys(
    final Set<LogicalKeyboardKey> keys,
  ) =>
      keys.map((final LogicalKeyboardKey x) => normalizeKey(x)).toSet();

  static LogicalKeyboardKey? fromLabel(final String label) =>
      nameCodeMap[label];

  static Set<LogicalKeyboardKey> fromLabels(final List<String> labels) => labels
      .map((final String x) => fromLabel(x))
      .whereType<LogicalKeyboardKey>()
      .toSet();

  static String toReadableLabel(final LogicalKeyboardKey key) =>
      readables[key] ?? key.keyLabel;

  static List<String> toLabels(final Set<LogicalKeyboardKey> keys) =>
      keys.map((final LogicalKeyboardKey x) => x.keyLabel).toList();
}
