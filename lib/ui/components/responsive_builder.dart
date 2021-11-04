import 'package:flutter/material.dart';
import './size_aware_builder.dart';
import '../../../modules/helpers/ui.dart';

class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    required final this.builders,
    final Key? key,
  })  : assert(builders.length > 0),
        super(key: key);

  final Map<int, SizeAwareWidgetBuilder> builders;

  @override
  Widget build(final BuildContext context) => SizeAwareBuilder(
        builder: (final BuildContext context, final ResponsiveSize size) =>
            (builders.entries.toList()
                  ..sort(
                    (
                      final MapEntry<int, SizeAwareWidgetBuilder> a,
                      final MapEntry<int, SizeAwareWidgetBuilder> b,
                    ) =>
                        b.key.compareTo(a.key),
                  ))
                .firstWhere(
                  (final MapEntry<int, SizeAwareWidgetBuilder> x) =>
                      size.width > x.key,
                )
                .value(context, size),
      );
}
