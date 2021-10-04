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

  static String render(
    final String template,
    final Map<String, String> context,
  ) =>
      template.replaceAllMapped(RegExp('{{{(.*?)}}}'), (final Match match) {
        final String key = match.group(1)!.trim();
        return context.containsKey(key) ? context[key]! : 'null';
      });

  static String pascalToSnakeCase(final String pascal) =>
      pascal.replaceAllMapped(
        RegExp('[A-Z]'),
        (final Match match) => '_${match.group(0)!.toLowerCase()}',
      );

  static String pascalPretty(final String pascal) => pascal.replaceAllMapped(
        RegExp('[A-Z]'),
        (final Match match) => ' ${match.group(0)!}',
      );
}
