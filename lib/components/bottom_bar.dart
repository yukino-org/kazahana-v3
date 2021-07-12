import 'package:flutter/material.dart';
import '../core/utils.dart' as utils;

class BottomBarItem {
  final String name;
  final IconData icon;
  final void Function() onPressed;

  BottomBarItem({
    required this.name,
    required this.icon,
    required this.onPressed,
  });
}

class BottomBar extends StatefulWidget {
  final List<BottomBarItem> items;
  final int initialIndex;

  const BottomBar({Key? key, required this.items, this.initialIndex = 0})
      : super(key: key);

  @override
  State<BottomBar> createState() => BottomBarState();
}

class BottomBarState extends State<BottomBar> {
  late int currentIndex = widget.initialIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: utils.remToPx(0.5),
          ),
        ],
      ),
      child: BottomAppBar(
        color: Theme.of(context).backgroundColor,
        child: Container(
          padding: EdgeInsets.all(utils.remToPx(0.2)),
          child: Wrap(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: widget.items
                    .asMap()
                    .map((i, x) {
                      final isActive = currentIndex == i;

                      final color = isActive
                          ? Theme.of(context).primaryColor
                          : Theme.of(context)
                              .textTheme
                              .bodyText1
                              ?.color
                              ?.withOpacity(0.7);

                      return MapEntry(
                        i,
                        MaterialButton(
                          padding: EdgeInsets.all(utils.remToPx(0.2)),
                          shape: const CircleBorder(),
                          child: Column(
                            children: [
                              Icon(x.icon,
                                  size: utils.remToPx(1.25), color: color),
                              SizedBox(height: utils.remToPx(0.1)),
                              Text(
                                x.name,
                                style: TextStyle(
                                  color: color,
                                ),
                              )
                            ],
                          ),
                          onPressed: () {
                            currentIndex = i;
                            x.onPressed();
                          },
                        ),
                      );
                    })
                    .values
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
