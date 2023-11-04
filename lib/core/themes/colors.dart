import 'package:flutter/material.dart';

abstract class ForegroundColors {
  static const Color red = Color(0xef4444ff);
  static const Color orange = Color(0xf97316ff);
  static const Color amber = Color(0xf59e0bff);
  static const Color yellow = Color(0xeab308ff);
  static const Color lime = Color(0x84cc16ff);
  static const Color green = Color(0x22c55eff);
  static const Color emerald = Color(0x10b981ff);
  static const Color teal = Color(0x14b8a6ff);
  static const Color cyan = Color(0x06b6d4ff);
  static const Color sky = Color(0x0ea5e9ff);
  static const Color blue = Color(0x3b82f6ff);
  static const Color indigo = Color(0x6366f1ff);
  static const Color violet = Color(0x8b5cf6ff);
  static const Color purple = Color(0xa855f7ff);
  static const Color fuchsia = Color(0xd946efff);
  static const Color pink = Color(0xec4899ff);
  static const Color rose = Color(0xf43f5eff);

  static const Map<String, Color> colors = <String, Color>{
    'red': red,
    'orange': orange,
    'amber': amber,
    'yellow': yellow,
    'lime': lime,
    'green': green,
    'emerald': emerald,
    'teal': teal,
    'cyan': cyan,
    'sky': sky,
    'blue': blue,
    'indigo': indigo,
    'violet': violet,
    'purple': purple,
    'fuchsia': fuchsia,
    'pink': pink,
    'rose': rose,
  };

  static Color? find(final String name) => colors[name];

  static List<String> names() => colors.keys.toList();
}
