import 'dart:convert';
import 'dart:math';

abstract class StringUtils {
  static String capitalize(final String string) => string.isNotEmpty
      ? '${string.substring(0, 1).toUpperCase()}${string.substring(1).toLowerCase()}'
      : string;

  static String random([final int inputLength = 6]) {
    final List<int> chars = utf8.encode(
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890-=',
    );
    final Random rand = Random();

    return base64
        .encode(
          List<int>.generate(
            inputLength,
            (final int i) => chars[rand.nextInt(chars.length)],
          ),
        )
        .replaceFirst(RegExp(r'[=]*$'), '');
  }

  static String type(
    final dynamic data, {
    final bool quotes = true,
  }) {
    final String result =
        RegExp("'([^']+)'").firstMatch(data.toString())?.group(1) ??
            data.toString();

    return quotes ? '"$result"' : result;
  }
}
