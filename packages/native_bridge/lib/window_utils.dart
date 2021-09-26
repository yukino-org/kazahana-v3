import './native_bridge.dart';

abstract class WindowUtils {
  static Future<void> focus() async {
    await NativeBridge.channel.invokeMethod('focusWindow');
  }
}
