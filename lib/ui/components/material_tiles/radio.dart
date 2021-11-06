import 'package:flutter/material.dart';
import './dialog.dart';

class RadioMaterialTile<T> extends StatelessWidget {
  const RadioMaterialTile({
    required final this.title,
    required final this.icon,
    required final this.value,
    required final this.labels,
    required final this.onChanged,
    final Key? key,
    final this.dialogTitle,
    final this.subtitle,
  }) : super(key: key);

  final Widget title;
  final Widget? dialogTitle;
  final Widget? subtitle;
  final Widget icon;
  final T value;
  final Map<T, String> labels;
  final void Function(T) onChanged;

  @override
  Widget build(final BuildContext context) => MaterialDialogTile(
        title: title,
        subtitle: Text(labels[value]!),
        icon: icon,
        dialogTitle: dialogTitle,
        dialogBuilder: (
          final BuildContext context,
          final StateSetter setState,
        ) =>
            Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: labels
              .map(
                (final T x, final String name) => MapEntry<T, Widget>(
                  x,
                  Material(
                    type: MaterialType.transparency,
                    child: RadioListTile<T>(
                      title: Text(name),
                      value: x,
                      groupValue: value,
                      activeColor: Theme.of(context).primaryColor,
                      onChanged: (final T? val) {
                        if (val != null && val != value) {
                          onChanged(val);
                        }

                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
              )
              .values
              .toList(),
        ),
      );
}
