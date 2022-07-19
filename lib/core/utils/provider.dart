import 'package:flutter/material.dart';

class StatedChangeNotifier extends ChangeNotifier {
  bool mounted = true;

  @override
  void dispose() {
    mounted = false;

    super.dispose();
  }
}
