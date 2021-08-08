import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OrientedWidget extends StatefulWidget {
  const OrientedWidget({
    required final this.child,
    required final this.orientation,
    final Key? key,
    final this.resetOrientation = const <DeviceOrientation>[],
  }) : super(key: key);

  final List<DeviceOrientation> orientation;
  final List<DeviceOrientation> resetOrientation;
  final Widget child;

  @override
  State<OrientedWidget> createState() => OrientedWidgetState();
}

class OrientedWidgetState extends State<OrientedWidget> {
  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations(widget.orientation);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(widget.resetOrientation);

    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => widget.child;
}
