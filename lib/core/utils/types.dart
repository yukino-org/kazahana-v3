typedef JsonMap = Map<dynamic, dynamic>;

Map<U, V> castJsonMap<U, V>(final dynamic value) =>
    (value as JsonMap).cast<U, V>();

List<T> castList<T>(final dynamic value) => (value as List<dynamic>).cast<T>();
