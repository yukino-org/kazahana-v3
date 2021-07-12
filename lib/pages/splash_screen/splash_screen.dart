import 'dart:async';
import 'package:flutter/material.dart';
import '../../plugins/router.dart';

class Screen extends StatefulWidget {
  const Screen({Key? key}) : super(key: key);

  @override
  ScreenState createState() => ScreenState();
}

class ScreenState extends State<Screen> {
  @override
  void initState() {
    super.initState();

    scheduleMicrotask(() {
      Navigator.of(context).pushReplacementNamed(RouteNames.home);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
          child: Center(
        child: CircularProgressIndicator(),
      )),
    );
  }
}
