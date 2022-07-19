import 'dart:convert';
import 'dart:typed_data';

abstract class AnimationDurations {
  static const Duration _defaultQuickAnimation = Duration(milliseconds: 100);
  static Duration get defaultQuickAnimation => _defaultQuickAnimation;

  static const Duration _defaultNormalAnimation = Duration(milliseconds: 300);
  static Duration get defaultNormalAnimation => _defaultNormalAnimation;

  static const Duration _defaultLongAnimation = Duration(milliseconds: 500);
  static Duration get defaultLongAnimation => _defaultLongAnimation;
}

abstract class Placeholders {
  static const String transparent1x1ImageBase64 =
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=';

  static final Uint8List transparent1x1Image =
      base64.decode(transparent1x1ImageBase64);
}
