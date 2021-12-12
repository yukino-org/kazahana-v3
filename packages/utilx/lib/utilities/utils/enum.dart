abstract class EnumUtils {
  static T find<T extends Enum>(final List<T> values, final String value) =>
      values.firstWhere((final T x) => x.name == value);

  static T? findOrNull<T extends Enum>(
    final List<T> values,
    final String? value,
  ) =>
      value != null
          ? values
              .cast<T?>()
              .firstWhere((final T? x) => x!.name == value, orElse: () => null)
          : null;
}
