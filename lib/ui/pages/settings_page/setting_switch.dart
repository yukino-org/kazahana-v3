import 'package:flutter/material.dart';
import '../../../modules/helpers/ui.dart';

class SettingSwitch extends StatelessWidget {
  const SettingSwitch({
    required final this.title,
    required final this.icon,
    required final this.value,
    required final this.onChanged,
    final Key? key,
    final this.desc,
  }) : super(key: key);

  final String title;
  final IconData icon;
  final String? desc;
  final bool value;
  final void Function(bool) onChanged;

  @override
  Widget build(final BuildContext context) => Material(
        type: MaterialType.transparency,
        child: InkWell(
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: TextStyle(
                          fontSize:
                              Theme.of(context).textTheme.subtitle1?.fontSize,
                        ),
                      ),
                      if (desc != null)
                        Text(
                          desc!,
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
                ),
                const SizedBox(width: 30),
                Switch(
                  value: value,
                  onChanged: onChanged,
                  activeColor: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
          onTap: () {
            onChanged(!value);
          },
        ),
      );
}
