import 'package:flutter/material.dart';

enum SettingsLabelWidgets { toggle, radio }

class SettingsCategory {
  final String title;
  final IconData icon;

  SettingsCategory({
    required this.title,
    required this.icon,
  });
}

class SettingsLabel {
  final String title;
  final String? headline;
  final String? desc;
  final IconData icon;
  final SettingsLabelWidgets type;
  final dynamic value;
  final Map<Object, String>? values;
  final void Function(dynamic) onChanged;

  SettingsLabel({
    required final this.title,
    final this.headline,
    final this.desc,
    required final this.icon,
    required final this.type,
    required final this.value,
    final this.values,
    required final this.onChanged,
  });
}
