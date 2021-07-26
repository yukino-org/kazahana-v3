import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OrientedWidget extends StatefulWidget {
  final List<DeviceOrientation> orientation;
  final List<DeviceOrientation> resetOrientation;
  final Widget child;

  const OrientedWidget({
    final Key? key,
    required final this.child,
    required final this.orientation,
    final this.resetOrientation = const [],
  }) : super(key: key);

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
  Widget build(final context) {
    return widget.child;
  }
}
