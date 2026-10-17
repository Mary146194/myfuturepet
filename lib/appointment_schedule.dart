/// Visiting hours already documented in the app: Mon–Sat, 9 AM–4 PM.
/// Slots are visit requests; shelter staff must confirm availability.
class AppointmentSchedule {
  static const manilaOffset = Duration(hours: 8);
  static const timeSlots = [
    '9:00 AM',
    '10:30 AM',
    '1:00 PM',
    '2:00 PM',
    '3:30 PM',
  ];

  /// Manila wall-clock fields, independent of the device's timezone.
  static DateTime inManila(DateTime instant) =>
      instant.toUtc().add(manilaOffset);

  static String formatTime(DateTime wallTime) {
    final hour = wallTime.hour % 12 == 0 ? 12 : wallTime.hour % 12;
    return '$hour:${wallTime.minute.toString().padLeft(2, '0')} '
        '${wallTime.hour < 12 ? 'AM' : 'PM'}';
  }

  /// Treat [date]'s calendar fields as a date at the shelter, not on the device.
  static DateTime scheduledUtc(DateTime date, String time) {
    if (!timeSlots.contains(time)) {
      throw ArgumentError('Select a valid visit time.');
    }
    final match = RegExp(r'^(\d{1,2}):(\d{2}) (AM|PM)$').firstMatch(time)!;
    final hour = int.parse(match[1]!) % 12 + (match[3] == 'PM' ? 12 : 0);
    return DateTime.utc(
      date.year,
      date.month,
      date.day,
      hour,
      int.parse(match[2]!),
    ).subtract(manilaOffset);
  }

  static bool isDateSelectable(DateTime date, DateTime now) {
    final today = inManila(now);
    final day = DateTime.utc(date.year, date.month, date.day);
    return day.weekday != DateTime.sunday &&
        !day.isBefore(DateTime.utc(today.year, today.month, today.day));
  }

  static bool isSlotSelectable(DateTime date, String time, DateTime now) =>
      isDateSelectable(date, now) &&
      timeSlots.contains(time) &&
      scheduledUtc(date, time).isAfter(now.toUtc());

  static DateTime firstBookableDate(DateTime now) {
    final wall = inManila(now);
    var date = DateTime.utc(wall.year, wall.month, wall.day);
    while (!timeSlots.any((time) => isSlotSelectable(date, time, now))) {
      date = date.add(const Duration(days: 1));
    }
    return date;
  }

  static void validateInstant(DateTime instant, DateTime now) {
    final wall = inManila(instant);
    if (wall.second != 0 ||
        wall.millisecond != 0 ||
        wall.microsecond != 0 ||
        !isSlotSelectable(wall, formatTime(wall), now)) {
      throw ArgumentError(
        'Choose a future visit slot, Monday to Saturday, in Philippine time.',
      );
    }
  }
}
