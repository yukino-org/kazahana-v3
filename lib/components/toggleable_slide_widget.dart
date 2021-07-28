import 'package:flutter/material.dart';

class ToggleableSlideWidget extends StatelessWidget {
  final Widget child;
  final AnimationController controller;
  final bool visible;
  final Offset offsetBegin;
  final Offset offsetEnd;

  const ToggleableSlideWidget({
    Key? key,
    required this.child,
    required this.controller,
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
          curve: Curves.fastOutSlowIn,
        ),
      ),
      child: child,
    );
  }
}
