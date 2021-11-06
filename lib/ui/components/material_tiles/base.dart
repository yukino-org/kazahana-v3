import 'package:flutter/material.dart';
import './utils.dart';

class MaterialTile extends StatelessWidget {
  const MaterialTile({
    required final this.title,
    required final this.icon,
    final Key? key,
    final this.subtitle,
    final this.trailing,
    final this.onTap,
    final this.active = false,
  }) : super(key: key);

  final Widget title;
  final Widget? subtitle;
  final Widget icon;
  final Widget? trailing;
  final void Function()? onTap;
  final bool active;

  @override
  Widget build(final BuildContext context) => MaterialTileUtils.buildWrapper(
        <Widget>[
          MaterialTileUtils.buildLeading(icon: icon),
          MaterialTileUtils.buildLeadingTitleSpacer(),
          MaterialTileUtils.buildTitle(
            title: title,
            subtitle: subtitle,
            active: active,
          ),
          if (trailing != null) ...<Widget>[
            MaterialTileUtils.buildTitleTrailingSpacer(),
            trailing!,
          ],
        ],
        onTap,
      );
}
