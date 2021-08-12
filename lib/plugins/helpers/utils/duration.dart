abstract class DurationUtils {
  static String pretty(final Duration duration) {
    final List<String> prettied = <String>[];
    final int hours = duration.inHours.remainder(24);
    if (hours != 0) prettied.add(hours.toString().padLeft(2, '0'));
    prettied.add(duration.inMinutes.remainder(60).toString().padLeft(2, '0'));
    prettied.add(duration.inSeconds.remainder(60).toString().padLeft(2, '0'));
    return prettied.join(':');
  }
}
