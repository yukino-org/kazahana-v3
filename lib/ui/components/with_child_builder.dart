import 'package:flutter/material.dart';

typedef WithChildBuilderBuilder = Widget Function(BuildContext, Widget);

class WithChildBuilder extends StatelessWidget {
  const WithChildBuilder({
    required final this.builder,
    required final this.child,
    final Key? key,
  }) : super(key: key);

  final WithChildBuilderBuilder builder;
  final Widget child;

  @override
  Widget build(final BuildContext context) => builder(context, child);
}
