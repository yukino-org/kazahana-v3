import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import './bar_item.dart';
import '../../modules/helpers/ui.dart';

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
  Widget build(final BuildContext context) {
    final double totalWidth = remToPx(2.4);
    final Size itemSize = Size(totalWidth, remToPx(1.7));
    final double totalHeight = widget.items.length * itemSize.height;
    final double tooltipFontSize =
        Theme.of(context).textTheme.bodyText1!.fontSize! + remToPx(0.1);

    return SizedBox(
      height: double.infinity,
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              height: totalHeight + (itemSize.height / 2),
              width: totalWidth,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.horizontal(
                    right: Radius.circular(remToPx(0.5)),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: totalWidth,
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
                              child: SizedBox(
                                width: itemSize.width,
                                height: itemSize.height,
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
          IgnorePointer(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(
                  left: totalWidth + remToPx(0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: widget.items
                      .asMap()
                      .map(
                        (final int i, final BarItem x) => MapEntry<int, Widget>(
                          i,
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 150),
                            opacity: currentIndex == i ? 1 : 0,
                            child: AnimatedScale(
                              alignment: Alignment.centerLeft,
                              scale: currentIndex == i ? 1 : 0.8,
                              duration: const Duration(milliseconds: 100),
                              child: SizedBox(
                                height: itemSize.height,
                                child: Material(
                                  color: Theme.of(context).cardColor,
                                  borderRadius:
                                      BorderRadius.circular(remToPx(0.3)),
                                  elevation: 16,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical:
                                          (itemSize.height - tooltipFontSize) /
                                              4,
                                      horizontal: remToPx(0.5),
                                    ),
                                    child: Text(
                                      x.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText1
                                          ?.copyWith(
                                            fontSize: tooltipFontSize,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                      .values
                      .toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
