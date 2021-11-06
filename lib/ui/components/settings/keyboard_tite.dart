import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../modules/helpers/keyboard.dart';
import '../../../modules/helpers/ui.dart';
import '../../../modules/translator/translator.dart';
import '../../../modules/utils/function.dart';
import '../material_tiles/base.dart';

class SettingsKeyboardTile extends StatefulWidget {
  const SettingsKeyboardTile({
    required final this.title,
    required final this.icon,
    required final this.keys,
    required final this.onChanged,
    final Key? key,
  }) : super(key: key);

  final Widget title;
  final Widget icon;
  final Set<LogicalKeyboardKey> keys;
  final FutureOr<void> Function(Set<LogicalKeyboardKey>) onChanged;

  @override
  State<SettingsKeyboardTile> createState() => _SettingsKeyboardTileState();
}

class _SettingsKeyboardTileState extends State<SettingsKeyboardTile> {
  final FocusNode focusNode = FocusNode();
  final Key k1 = UniqueKey();
  final Key k2 = UniqueKey();

  bool editing = false;
  final Set<LogicalKeyboardKey> pressed = <LogicalKeyboardKey>{};

  @override
  void dispose() {
    focusNode.dispose();

    super.dispose();
  }

  void startEditing() {
    focusNode.requestFocus();

    setState(() {
      editing = true;
      pressed.clear();
    });
  }

  void endEditing() {
    focusNode.unfocus();

    setState(() {
      editing = false;
      pressed.clear();
    });
  }

  void onKeyEvent(final RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      setState(() {
        pressed.add(KeyboardHandler.normalizeKey(event.logicalKey));
      });
    }
  }

  String keysToText(final Set<LogicalKeyboardKey> keys) => keys
      .map((final LogicalKeyboardKey x) => KeyboardHandler.toReadableLabel(x))
      .join(' + ');

  @override
  Widget build(final BuildContext context) => FunctionUtils.withValue(
        Theme.of(context),
        (final ThemeData theme) => RawKeyboardListener(
          focusNode: focusNode,
          onKey: onKeyEvent,
          child: MaterialTile(
            title: widget.title,
            icon: widget.icon,
            subtitle: editing
                ? Text(
                    pressed.isNotEmpty
                        ? keysToText(pressed)
                        : Translator.t.waitingForKeyStrokes(),
                  )
                : Text(keysToText(widget.keys)),
            trailing: editing
                ? Row(
                    key: k1,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        splashRadius: remToPx(1),
                        onPressed: () async {
                          if (pressed.isNotEmpty) {
                            await widget.onChanged(pressed);
                          }

                          endEditing();
                        },
                        icon: const Icon(
                          Icons.check,
                          color: Colors.green,
                        ),
                      ),
                      IconButton(
                        splashRadius: remToPx(1),
                        onPressed: endEditing,
                        icon: const Icon(
                          Icons.close,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  )
                : IconButton(
                    key: k2,
                    splashRadius: remToPx(1),
                    onPressed: startEditing,
                    icon: Icon(
                      Icons.edit,
                      color: theme.primaryColor,
                    ),
                  ),
          ),
        ),
      );
}
