import 'package:flutter/material.dart';
import 'base.dart';

class MaterialSwitchTile extends StatelessWidget {
  const MaterialSwitchTile({
    required final this.title,
    required final this.icon,
    required final this.value,
    required final this.onChanged,
    final Key? key,
    final this.subtitle,
  }) : super(key: key);

  final Widget title;
  final Widget? subtitle;
  final Widget icon;
  final bool value;
  final void Function(bool) onChanged;

  @override
  Widget build(final BuildContext context) => MaterialTile(
        icon: icon,
        title: title,
        subtitle: subtitle,
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Theme.of(context).primaryColor,
        ),
        onTap: () {
          onChanged(!value);
        },
      );
}
