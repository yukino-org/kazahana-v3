import 'package:flutter/material.dart';

class ToggleableSlideWidget extends StatelessWidget {
  const ToggleableSlideWidget({
    required final this.child,
    required final this.controller,
    required final this.curve,
    required final this.visible,
    required final this.offsetBegin,
    required final this.offsetEnd,
    final Key? key,
  }) : super(key: key);

  final Widget child;
  final AnimationController controller;
  final Curve curve;
  final bool visible;
  final Offset offsetBegin;
  final Offset offsetEnd;

  @override
  Widget build(final BuildContext context) {
    visible ? controller.reverse() : controller.forward();
    return SlideTransition(
      position: Tween<Offset>(
        begin: offsetBegin,
        end: offsetEnd,
      ).animate(
        CurvedAnimation(
          parent: controller,
          curve: curve,
        ),
      ),
      child: child,
    );
  }
}
