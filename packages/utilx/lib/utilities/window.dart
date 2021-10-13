import './channel.dart';

abstract class WindowUtils {
  /// Supports only **Windows**
  static Future<void> focus() async {
    await NativeBridge.channel.invokeMethod('focusWindow');
  }
}
