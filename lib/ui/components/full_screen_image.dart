import 'package:flutter/material.dart';
import '../../config/defaults.dart';

class FullScreenInteractiveImage extends StatefulWidget {
  const FullScreenInteractiveImage({
    required final this.child,
    final Key? key,
  }) : super(key: key);

  final Widget child;

  @override
  _FullScreenInteractiveImageState createState() =>
      _FullScreenInteractiveImageState();
}

class _FullScreenInteractiveImageState extends State<FullScreenInteractiveImage>
    with SingleTickerProviderStateMixin {
  late TransformationController transformationController;
  late AnimationController animationController;
  late Matrix4Tween tween;
  late Animation<Matrix4> animation;

  TapDownDetails? lastDoubleTapDetail;

  @override
  void initState() {
    super.initState();

    transformationController = TransformationController();
    animationController = AnimationController(
      duration: Defaults.animationsFaster,
      vsync: this,
    );

    tween = Matrix4Tween();
    animation = tween.animate(animationController);
    animation.addListener(animationListener);
  }

  @override
  void dispose() {
    animation.removeListener(animationListener);

    transformationController.dispose();
    animationController.dispose();

    super.dispose();
  }

  void animationListener() {
    transformationController.value = animation.value;
  }

  void animate({
    required final Matrix4 end,
    final Matrix4? begin,
  }) {
    tween.begin = begin ?? transformationController.value;
    tween.end = end;

    animationController.reset();
    animationController.forward();
  }

  @override
  Widget build(final BuildContext context) => Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: GestureDetector(
                child: InteractiveViewer(
                  transformationController: transformationController,
                  child: widget.child,
                ),
                onDoubleTap: () {
                  if (lastDoubleTapDetail != null) {
                    final Offset position = lastDoubleTapDetail!.localPosition;
                    if (transformationController.value.isIdentity()) {
                      animate(
                        end: Matrix4.identity()
                          ..translate(
                            -position.dx * 2,
                            -position.dy * 2,
                          )
                          ..scale(3.0),
                      );
                    } else {
                      animate(
                        end: Matrix4.identity(),
                      );
                    }
                    lastDoubleTapDetail = null;
                  }
                },
                onDoubleTapDown: (final TapDownDetails details) {
                  lastDoubleTapDetail = details;
                },
              ),
            ),
          ],
        ),
      );
}
