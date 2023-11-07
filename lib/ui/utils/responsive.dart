import 'package:kazahana/core/exports.dart';

class Responsive extends InheritedWidget {
  const Responsive({
    required this.width,
    required super.child,
    super.key,
  });

  factory Responsive.of(final BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<Responsive>()!;

  final double width;

  T value<T>(
    final T any, {
    final T? sm,
    final T? md,
    final T? lg,
    final T? xl,
  }) =>
      switch (width) {
        > xlWidth when xl != null => xl,
        > lgWidth when lg != null => lg,
        > mdWidth when md != null => md,
        > smWidth when sm != null => sm,
        _ => any,
      };

  @override
  bool updateShouldNotify(final Responsive oldWidget) =>
      oldWidget.width != width;

  static const double smWidth = 640;
  static const double mdWidth = 768;
  static const double lgWidth = 1024;
  static const double xlWidth = 1280;
}

extension ResponsiveUtils on BuildContext {
  Responsive get m => Responsive.of(this);
}
