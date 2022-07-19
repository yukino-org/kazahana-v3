import '../../../core/exports.dart';
import '../_home/view.dart';
import '../_splash/view.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    final Key? key,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    AppLoader.initialize().then((final _) async {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(final BuildContext context) => PageTransitionSwitcher(
        duration: AnimationDurations.defaultLongAnimation,
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
