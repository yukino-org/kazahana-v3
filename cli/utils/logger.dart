// ignore_for_file: avoid_print

class Logger {
  const Logger(this.name);

  final String name;

  void info(final Object text) {
    print('[$time info] $name: $text');
  }

  void fatal(final Object text) {
    print('[$time err!] $name: $text');
  }

  void println() {
    print(' ');
  }

  String get time {
    final DateTime now = DateTime.now();
    return '${now.hour}:${now.minute}:${now.second}';
  }
}
