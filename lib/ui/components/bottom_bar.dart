import 'package:flutter/material.dart';
import './bar_item.dart';
import '../../modules/helpers/ui.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({
    required final this.items,
    final Key? key,
  }) : super(key: key);

  final List<BarItem> items;

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
                children: items.map((final BarItem x) {
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
                                items.length /
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
