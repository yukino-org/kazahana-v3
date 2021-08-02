import 'package:flutter/material.dart';
import '../../core/utils.dart' as utils;

class SettingSwitch extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? desc;
  final bool value;
  final void Function(bool) onChanged;

  const SettingSwitch({
    Key? key,
    required this.title,
    required this.icon,
    this.desc,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: utils.remToPx(0.9),
            vertical: utils.remToPx(0.5),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 30),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.subtitle1?.fontSize,
                      ),
                    ),
                    desc != null
                        ? Text(
                            desc!,
                            style: TextStyle(
                              fontSize: Theme.of(context)
                                  .textTheme
                                  .subtitle2
                                  ?.fontSize,
                              color: Theme.of(context).textTheme.caption?.color,
                            ),
                          )
                        : const SizedBox.shrink(),
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
}
