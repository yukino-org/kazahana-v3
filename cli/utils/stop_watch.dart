class StopWatch {
  StopWatch();

  factory StopWatch.createAndStart() => StopWatch().start();

  DateTime? startedAt;
  DateTime? stoppedAt;

  StopWatch start() {
    startedAt = DateTime.now();
    return this;
  }

  int stop() {
    stoppedAt = DateTime.now();
    return took;
  }

  int get took =>
      stoppedAt!.millisecondsSinceEpoch - startedAt!.millisecondsSinceEpoch;
}
