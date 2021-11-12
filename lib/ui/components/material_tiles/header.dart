import 'package:flutter/material.dart';
import '../../../modules/helpers/ui.dart';
import '../../../modules/utils/utils.dart';

class MaterialHeaderTile extends StatelessWidget {
  const MaterialHeaderTile({
    required final this.text,
    final Key? key,
    final this.topPadding = true,
  }) : super(key: key);

  final Widget text;
  final bool topPadding;

  @override
  Widget build(final BuildContext context) => FunctionUtils.withValue(
        Theme.of(context),
        (final ThemeData theme) => Padding(
          padding: EdgeInsets.only(
            left: remToPx(0.9),
            right: remToPx(0.9),
            top: remToPx(topPadding ? 0.8 : 0.4),
            bottom: remToPx(0.4),
          ),
          child: DefaultTextStyle(
            style: theme.textTheme.subtitle1!.copyWith(
              color: theme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
            child: text,
          ),
        ),
      );
}
