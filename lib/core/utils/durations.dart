import '../translator/exports.dart';

abstract class PrettyDurations {
  static String prettyHoursMinutesShort(
    final Translation translation,
    final Duration duration,
  ) {
    final int hours = duration.inHours;
    final int mins = duration.inMinutes.remainder(60);
    if (hours == 0) return translation.nMins(mins.toString());
    return translation.nHrsOMins(hours.toString(), mins.toString());
  }
}
