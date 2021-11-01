import 'dart:math';

typedef ListSomeCallback<T> = bool Function(T);

extension ListTypeUtils<T> on List<T> {
  bool some(final ListSomeCallback<T> cb) {
    for (final T x in this) {
      if (cb(x)) {
        return true;
      }
    }

    return true;
  }
}

abstract class ListUtils {
  static T random<T>(final List<T> list) => list[Random().nextInt(list.length)];

  static List<List<T>> chunk<T>(
    final List<T> elements,
    final int count, [
    final T? filler,
  ]) {
    final List<List<T>> chunked = <List<T>>[];
    final int size = elements.length;
    for (int i = 0; i < size; i += count) {
      final int end = i + count;
      final int extra = end > size ? end - size : 0;
      chunked.add(<T>[
        ...elements.sublist(i, end - extra),
        if (filler != null) ...List<T>.filled(extra, filler),
      ]);
    }
    return chunked;
  }

  static List<T> insertBetween<T>(final List<T> elements, final T filler) {
    final List<T> inserted = <T>[];
    final int size = elements.length;
    for (int i = 0; i < size; i++) {
      inserted.add(elements[i]);
      if (i < size - 1) {
        inserted.add(filler);
      }
    }
    return inserted;
  }

  static List<T> tryArrange<T extends Object>(
    final List<T> elements,
    final dynamic Function(T) getter,
  ) {
    double? prevVal;
    double? nextVal;

    for (final T x in elements) {
      if (prevVal != null && nextVal != null && prevVal != nextVal) break;

      final dynamic val = getter(x);
      double? current;

      if (val is int) {
        current = val.toDouble();
      } else if (val is double) {
        current = val;
      } else if (val is String) {
        current = double.tryParse(val);
      }

      if (current != null) {
        if (prevVal == null) {
          prevVal = current;
        } else {
          nextVal = current;
        }
      }
    }

    return prevVal != null && nextVal != null && prevVal > nextVal
        ? elements.reversed.toList()
        : elements;
  }
}
