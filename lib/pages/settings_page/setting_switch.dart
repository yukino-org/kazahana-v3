import 'package:flutter/material.dart';

class SettingSwitch extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? desc;
  final bool value;
  final void Function(bool) onChanged;

  const SettingSwitch({
    Key? key,
    required this.title,
    required this.icon,
    this.desc,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: SwitchListTile(
        title: Text(title),
        secondary: Icon(
          icon,
          color: Theme.of(context).primaryColor,
        ),
        subtitle: desc != null ? Text(desc!) : null,
        value: value,
        activeColor: Theme.of(context).primaryColor,
        onChanged: onChanged,
      ),
    );
  }
}
