import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import './home_page.dart' as home_page;
import './splash_page.dart' as splash_page;
import '../../plugins/app_lifecycle.dart';

class Page extends StatefulWidget {
  const Page({
    final Key? key,
  }) : super(key: key);

  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<Page> {
  @override
  Widget build(final BuildContext context) => PageTransitionSwitcher(
        transitionBuilder: (
          final Widget child,
          final Animation<double> animation,
          final Animation<double> secondaryAnimation,
        ) =>
            SharedAxisTransition(
          fillColor: Theme.of(context).scaffoldBackgroundColor,
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.scaled,
          child: child,
        ),
        child: AppLifecycle.ready
            ? const home_page.Page()
            : splash_page.Page(
                refresh: () {
                  setState(() {});
                },
              ),
      );
}
