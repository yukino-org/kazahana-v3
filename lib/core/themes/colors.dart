import 'package:flutter/material.dart';
import '../translator/exports.dart';

abstract class ForegroundColors {
  static const Color red = Color(0xffef4444);
  static const Color orange = Color(0xfff97316);
  static const Color amber = Color(0xfff59e0b);
  static const Color yellow = Color(0xffeab308);
  static const Color lime = Color(0xff84cc16);
  static const Color green = Color(0xff22c55e);
  static const Color emerald = Color(0xff10b981);
  static const Color teal = Color(0xff14b8a6);
  static const Color cyan = Color(0xff06b6d4);
  static const Color sky = Color(0xff0ea5e9);
  static const Color blue = Color(0xff3b82f6);
  static const Color indigo = Color(0xff6366f1);
  static const Color violet = Color(0xff8b5cf6);
  static const Color purple = Color(0xffa855f7);
  static const Color fuchsia = Color(0xffd946ef);
  static const Color pink = Color(0xffec4899);
  static const Color rose = Color(0xfff43f5e);

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

  static String getTitleCase(
    final Translation translation,
    final String name,
  ) =>
      switch (name) {
        'red' => translation.red,
        'orange' => translation.orange,
        'amber' => translation.amber,
        'yellow' => translation.yellow,
        'lime' => translation.lime,
        'green' => translation.green,
        'emerald' => translation.emerald,
        'teal' => translation.teal,
        'cyan' => translation.cyan,
        'sky' => translation.sky,
        'blue' => translation.blue,
        'indigo' => translation.indigo,
        'violet' => translation.violet,
        'purple' => translation.purple,
        'fuchsia' => translation.fuchsia,
        'pink' => translation.pink,
        'rose' => translation.rose,
        _ => name,
      };
}
