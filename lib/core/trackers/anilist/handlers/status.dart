enum Statuses {
  current,
  planning,
  completed,
  dropped,
  paused,
  repeating,
}

extension StatusesUtils on Statuses {
  String get status => toString().split('.').last;
}

Statuses stringToStatus(final String status) =>
    Statuses.values.firstWhere((final Statuses x) => x.status == status);
