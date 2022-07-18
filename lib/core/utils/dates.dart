abstract class PrettyDates {
  static String constructDateString({
    required final String day,
    required final String month,
    required final String year,
  }) =>
      '$day-$month-$year';

  static String toDateString(final DateTime date) => constructDateString(
        day: date.day.toString(),
        month: date.month.toString(),
        year: date.year.toString(),
      );
}
