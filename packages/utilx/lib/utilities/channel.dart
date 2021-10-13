import 'package:flutter/services.dart';

abstract class NativeBridge {
  static const MethodChannel channel = MethodChannel('utilx');
}
