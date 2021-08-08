import 'package:flutter/material.dart';

class ToggleableAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ToggleableAppBar({
    required final this.child,
    required final this.controller,
    required final this.visible,
    final Key? key,
  }) : super(key: key);

  final PreferredSizeWidget child;
  final AnimationController controller;
  final bool visible;

  @override
  Size get preferredSize => child.preferredSize;

  @override
  Widget build(final BuildContext context) {
    visible ? controller.reverse() : controller.forward();
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(0, -1),
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
