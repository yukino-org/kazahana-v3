abstract class StringUtils {
  static String capitalize(final String string) => string.isNotEmpty
      ? '${string.substring(0, 1).toUpperCase()}${string.substring(1).toLowerCase()}'
      : string;
}
