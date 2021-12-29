import 'package:flutter/material.dart';

typedef PreferredSizeWrapperFromChildBuilder = Widget Function(
  BuildContext,
  PreferredSizeWidget,
);

class PreferredSizeWrapper extends StatelessWidget
    implements PreferredSizeWidget {
  const PreferredSizeWrapper({
    required final this.builder,
    required final this.size,
    final Key? key,
  }) : super(key: key);

  factory PreferredSizeWrapper.fromChild({
    required final PreferredSizeWrapperFromChildBuilder builder,
    required final PreferredSizeWidget child,
  }) =>
      PreferredSizeWrapper(
        builder: (final BuildContext context) => builder(context, child),
        size: child.preferredSize,
      );

  final WidgetBuilder builder;
  final Size size;

  @override
  Widget build(final BuildContext context) => builder(context);

  @override
  Size get preferredSize => size;
}
