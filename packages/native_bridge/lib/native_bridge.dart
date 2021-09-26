library native_bridge;

import 'package:flutter/services.dart';

abstract class NativeBridge {
  static const MethodChannel channel = MethodChannel('native_bridge');
}
