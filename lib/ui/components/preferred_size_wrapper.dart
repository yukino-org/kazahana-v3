import 'package:flutter/material.dart';

typedef PreferredSizeWrapperBuilder = Widget Function(
  BuildContext,
  PreferredSizeWidget,
);

class PreferredSizeWrapper extends StatelessWidget
    implements PreferredSizeWidget {
  const PreferredSizeWrapper({
    required final this.builder,
    required final this.child,
    final Key? key,
  }) : super(key: key);

  final PreferredSizeWrapperBuilder builder;
  final PreferredSizeWidget child;

  @override
  Widget build(final BuildContext context) => builder(context, child);

  @override
  Size get preferredSize => child.preferredSize;
}
