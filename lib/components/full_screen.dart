import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FullScreenWidget extends StatefulWidget {
  final Widget child;

  const FullScreenWidget({Key? key, required this.child}) : super(key: key);

  @override
  FullScreenState createState() => FullScreenState();
}

class FullScreenState extends State<FullScreenWidget> {
  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIOverlays([]);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Container(
        color: Colors.black,
        child: widget.child,
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);

    super.dispose();
  }
}
