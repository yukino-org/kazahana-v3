import 'dart:math';

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
      final List<T> chunk = elements.sublist(i, end - extra);
      if (filler != null) {
        for (int i = 0; i < extra; i++) {
          chunk.add(filler);
        }
      }
      chunked.add(chunk);
    }
    return chunked;
  }

  static List<T> insertBetween<T>(final List<T> elements, final T insert) {
    final List<T> inserted = <T>[];
    final int size = elements.length;
    for (int i = 0; i < size; i++) {
      if (i != 0 && i < size) {
        inserted.add(insert);
      }
      inserted.add(elements[i]);
    }
    return inserted;
  }

  static List<T> tryArrange<T extends Object>(
    final List<T> elements,
    final dynamic Function(T) getter,
  ) {
    double? prevVal, nextVal;

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
