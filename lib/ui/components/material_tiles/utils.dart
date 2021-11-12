import 'package:flutter/material.dart';
import '../../../modules/helpers/ui.dart';
import '../../../modules/utils/utils.dart';

abstract class MaterialTileUtils {
  static Widget buildWrapper(
    final List<Widget> children, [
    final void Function()? onTap,
  ]) =>
      Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: remToPx(2.5)),
            child: Padding(
              padding: EdgeInsets.all(remToPx(0.4)),
              child: Row(children: children),
            ),
          ),
        ),
      );

  static Widget buildLeading({
    required final Widget icon,
  }) =>
      Builder(
        builder: (final BuildContext context) => SizedBox(
          width: remToPx(2.1),
          child: IconTheme(
            data: IconThemeData(color: Theme.of(context).primaryColor),
            child: icon,
          ),
        ),
      );

  static Widget buildLeadingTitleSpacer() => SizedBox(width: remToPx(0.8));

  static Widget buildTitle({
    required final Widget title,
    final Widget? subtitle,
    final bool active = false,
  }) =>
      Expanded(
        child: Builder(
          builder: (final BuildContext context) => FunctionUtils.withValue(
            Theme.of(context),
            (final ThemeData theme) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                DefaultTextStyle(
                  style: theme.textTheme.subtitle1!.copyWith(
                    color: active ? theme.primaryColor : null,
                  ),
                  child: title,
                ),
                if (subtitle != null)
                  DefaultTextStyle(
                    style: theme.textTheme.subtitle2!.copyWith(
                      color: theme.textTheme.caption?.color,
                    ),
                    child: subtitle,
                  ),
              ],
            ),
          ),
        ),
      );

  static Widget buildTitleTrailingSpacer() => SizedBox(width: remToPx(1.5));
}
