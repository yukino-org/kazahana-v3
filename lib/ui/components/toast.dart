import 'package:kazahana/core/exports.dart';
import '../utils/exports.dart';
import 'super_imposer.dart';

class Toast extends StatefulWidget {
  const Toast({
    required this.content,
    this.duration = defaultToastDuration,
    this.animationDuration,
    super.key,
  });

  final Widget content;
  final Duration duration;
  final Duration? animationDuration;

  @override
  State<Toast> createState() => _ToastState();

  Future<void> show() async => showToast(this);

  Duration get resolvedAnimationDuration =>
      animationDuration ?? AnimationDurations.defaultNormalAnimation;

  static const Duration defaultToastDuration = Duration(seconds: 3);

  static Future<void> showToast(final Toast toast) async {
    final SuperImposerEntry entry = SuperImposerEntry.create(
      (final _) => Align(
        alignment: Alignment.bottomCenter,
        child: toast,
      ),
    );
    SuperImposer.insert(entry);
    await Future<void>.delayed(
      toast.duration + (toast.resolvedAnimationDuration * 2),
    );
    SuperImposer.remove(entry);
  }
}

class _ToastState extends State<Toast> {
  bool visible = false;

  @override
  void initState() {
    super.initState();

    Future<void>.microtask(() async {
      setState(() {
        visible = true;
      });

      await Future<void>.delayed(widget.duration);
      if (!mounted) return;

      setState(() {
        visible = false;
      });
    });
  }

  @override
  Widget build(final BuildContext context) => AnimatedSwitcher(
        duration: widget.resolvedAnimationDuration,
        transitionBuilder:
            (final Widget child, final Animation<double> animation) =>
                FadeScaleTransition(animation: animation, child: child),
        child: visible
            ? Padding(
                padding: EdgeInsets.all(context.r.size(0.4)),
                child: SizedBox(
                  width: double.infinity,
                  child: Material(
                    color: Colors.transparent,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Theme.of(context).bottomAppBarColor,
                        borderRadius:
                            BorderRadius.circular(context.r.size(0.25)),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(context.r.size(0.5)),
                        child: Row(
                          children: <Widget>[
                            widget.content,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink(),
      );
}
