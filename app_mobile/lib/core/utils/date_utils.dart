class AppDateUtils {
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return now.year == date.year &&
        now.month == date.month &&
        now.day == date.day;
  }

  static bool isFuture(DateTime date) {
    return date.isAfter(DateTime.now());
  }

  static int differenceInDays(DateTime a, DateTime b) {
    return a.difference(b).inDays;
  }
}
