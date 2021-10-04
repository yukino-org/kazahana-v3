enum ListType {
  anime,
  manga,
}

extension ListTypeUtils on ListType {
  String get type => toString().split('.').last.toUpperCase();
}
