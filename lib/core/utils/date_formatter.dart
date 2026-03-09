import 'package:intl/intl.dart';

/// Date formatting utilities.
class DateFormatter {
  DateFormatter._();

  /// "25 Feb 2026"
  static String formatFull(DateTime date) =>
      DateFormat('d MMM yyyy').format(date);

  /// "25 Feb"
  static String formatShort(DateTime date) => DateFormat('d MMM').format(date);

  /// "February 2026"
  static String formatMonth(DateTime date) =>
      DateFormat('MMMM yyyy').format(date);

  /// "Today", "Yesterday", or "25 Feb"
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return DateFormat('EEEE').format(date); // "Monday"
    return formatShort(date);
  }
}
