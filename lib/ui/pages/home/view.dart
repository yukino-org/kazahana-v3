import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import '../../../core/exports.dart';
import '../_home/view.dart';
import '../_splash/view.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    final Key? key,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    // AppLoader.initialize().then((final _) async {
    //   if (mounted) {
    //     setState(() {});
    //   }
    // });
  }

  @override
  Widget build(final BuildContext context) => PageTransitionSwitcher(
        transitionBuilder: (
          final Widget child,
          final Animation<double> animation,
          final Animation<double> secondaryAnimation,
        ) =>
            FadeThroughTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        ),
        child: AppLoader.ready
            ? const UnderScoreHomePage()
            : const UnderScoreSplashPage(),
      );
}
