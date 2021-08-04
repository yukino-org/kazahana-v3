import 'package:flutter/material.dart';

class SettingTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final void Function()? onTap;

  const SettingTile({
    Key? key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 42,
                child: Icon(
                  icon,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: Theme.of(context).textTheme.subtitle1?.fontSize,
                    ),
                  ),
                  subtitle != null
                      ? Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize:
                                Theme.of(context).textTheme.subtitle2?.fontSize,
                            color: Theme.of(context).textTheme.caption?.color,
                          ),
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            ],
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
