import 'package:flutter/material.dart';
import '../../plugins/helpers/ui.dart';

class SettingTile extends StatelessWidget {
  const SettingTile({
    required final this.title,
    required final this.icon,
    final Key? key,
    final this.subtitle,
    final this.onTap,
  }) : super(key: key);

  final String title;
  final String? subtitle;
  final IconData icon;
  final void Function()? onTap;

  @override
  Widget build(final BuildContext context) => Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: remToPx(2.1),
                  child: Icon(
                    icon,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(width: remToPx(0.8)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.subtitle1?.fontSize,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize:
                              Theme.of(context).textTheme.subtitle2?.fontSize,
                          color: Theme.of(context).textTheme.caption?.color,
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
}
