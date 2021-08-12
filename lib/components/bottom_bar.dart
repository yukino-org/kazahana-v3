import 'package:flutter/material.dart';
import '../plugins/helpers/ui.dart';

class BottomBarItem {
  BottomBarItem({
    required final this.name,
    required final this.icon,
    required final this.onPressed,
    required final this.isActive,
  });

  final String name;
  final IconData icon;
  final void Function() onPressed;
  bool isActive;
}

class BottomBar extends StatefulWidget {
  const BottomBar({
    required final this.items,
    final Key? key,
    final this.initialIndex = 0,
  }) : super(key: key);

  final List<BottomBarItem> items;
  final int initialIndex;

  @override
  State<BottomBar> createState() => BottomBarState();
}

class BottomBarState extends State<BottomBar> {
  late int currentIndex = widget.initialIndex;

  @override
  Widget build(final BuildContext context) => Container(
        decoration: BoxDecoration(
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: isDarkContext(context)
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.1),
              blurRadius: remToPx(0.5),
            ),
          ],
        ),
        child: BottomAppBar(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Wrap(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: widget.items.map((final BottomBarItem x) {
                  final Color? color = x.isActive
                      ? Theme.of(context).primaryColor
                      : Theme.of(context)
                          .textTheme
                          .bodyText1
                          ?.color
                          ?.withOpacity(0.7);

                  return Expanded(
                    child: Material(
                      type: MaterialType.transparency,
                      child: InkResponse(
                        onTap: x.onPressed,
                        radius: (MediaQuery.of(context).size.width /
                                widget.items.length /
                                2) -
                            remToPx(1),
                        child: Padding(
                          padding: EdgeInsets.all(remToPx(0.25)),
                          child: Column(
                            children: <Widget>[
                              Icon(
                                x.icon,
                                size: remToPx(1.25),
                                color: color,
                              ),
                              SizedBox(height: remToPx(0.1)),
                              Text(
                                x.name,
                                style: TextStyle(
                                  color: color,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      );
}
