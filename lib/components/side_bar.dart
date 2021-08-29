import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import './bar_item.dart';
import '../../plugins/helpers/ui.dart';

class SideBar extends StatefulWidget {
  const SideBar({
    required final this.items,
    final Key? key,
  }) : super(key: key);

  final List<BarItem> items;

  @override
  _SideBarState createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  int? currentIndex;

  @override
  Widget build(final BuildContext context) => SizedBox(
        height: double.infinity,
        width: remToPx(2.3),
        child: Stack(
          children: <Widget>[
            Align(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  vertical: remToPx(0.5),
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.horizontal(
                    right: Radius.circular(remToPx(0.5)),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: widget.items
                      .asMap()
                      .map(
                        (final int i, final BarItem x) {
                          final bool isHovered = currentIndex == i;
                          final Color? color = x.isActive
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).brightness == Brightness.dark
                                  ? Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      ?.color
                                      ?.withOpacity(
                                        isHovered ? 0.5 : 0.7,
                                      )
                                  : isHovered
                                      ? Palette.gray[600]
                                      : Palette.gray[500];

                          return MapEntry<int, Widget>(
                            i,
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              onEnter: (final PointerEnterEvent event) {
                                setState(() {
                                  currentIndex = i;
                                });
                              },
                              onExit: (final PointerExitEvent event) {
                                setState(() {
                                  currentIndex = null;
                                });
                              },
                              child: GestureDetector(
                                onTap: x.onPressed,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: remToPx(0.25),
                                  ),
                                  child: Icon(
                                    x.icon,
                                    size: remToPx(1.25),
                                    color: color,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      )
                      .values
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      );
}
