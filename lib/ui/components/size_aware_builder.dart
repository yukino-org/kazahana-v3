import 'package:flutter/material.dart';
import '../../../modules/helpers/ui.dart';

typedef SizeAwareWidgetBuilder = Widget Function(
  BuildContext,
  ResponsiveSize,
);

class SizeAwareBuilder extends StatelessWidget {
  const SizeAwareBuilder({
    required final this.builder,
    final Key? key,
  }) : super(key: key);

  final SizeAwareWidgetBuilder builder;

  @override
  Widget build(final BuildContext context) =>
      builder(context, ResponsiveSize.fromContext(context));
}
