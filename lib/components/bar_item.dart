import 'package:flutter/material.dart';

class BarItem {
  BarItem({
    required final this.name,
    required final this.icon,
    required final this.onPressed,
    required final this.isActive,
  });

  final String name;
  final IconData icon;
  final void Function() onPressed;
  bool isActive;
}
