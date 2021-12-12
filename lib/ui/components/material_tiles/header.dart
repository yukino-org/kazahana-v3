import 'package:flutter/material.dart';
import 'package:utilx/utilities/utils.dart';
import '../../../modules/helpers/ui.dart';

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
            textAlign: TextAlign.left,
            style: theme.textTheme.subtitle1!.copyWith(
              color: theme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
            child: text,
          ),
        ),
      );
}
