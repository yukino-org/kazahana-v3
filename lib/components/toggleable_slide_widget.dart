import 'package:flutter/material.dart';

class ToggleableSlideWidget extends StatelessWidget {
  final Widget child;
  final AnimationController controller;
  final Curve curve;
  final bool visible;
  final Offset offsetBegin;
  final Offset offsetEnd;

  const ToggleableSlideWidget({
    Key? key,
    required this.child,
    required this.controller,
    required this.curve,
    required this.visible,
    required this.offsetBegin,
    required this.offsetEnd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
