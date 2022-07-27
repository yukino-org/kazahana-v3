import '../translator/exports.dart';

abstract class PrettyDurations {
  static String prettyHoursMinutesShort({
    required final Duration duration,
    required final Translations translations,
  }) {
    final int hours = duration.inHours;
    final int mins = duration.inMinutes.remainder(60);
    if (hours == 0) return translations.nMins(mins.toString());
    return translations.nHrsNMins(hours.toString(), mins.toString());
  }
}
