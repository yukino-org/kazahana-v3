import 'dart:convert';
import 'dart:typed_data';

abstract class Placeholders {
  static const String transparent1x1ImageBase64 =
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=';

  static final Uint8List transparent1x1Image =
      base64.decode(transparent1x1ImageBase64);
}
