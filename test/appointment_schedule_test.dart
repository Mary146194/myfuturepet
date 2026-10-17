import 'package:flutter_test/flutter_test.dart';
import 'package:myfuturepet/appointment_schedule.dart';

void main() {
  final now = DateTime.utc(2026, 10, 19, 0); // Monday, 8 AM in Jagna.

  test('Selected calendar day and AM/PM slot map to the exact UTC instant', () {
    expect(
      AppointmentSchedule.scheduledUtc(DateTime(2026, 10, 20), '9:00 AM'),
      DateTime.utc(2026, 10, 20, 1),
    );
    expect(
      AppointmentSchedule.scheduledUtc(DateTime(2026, 10, 20), '1:00 PM'),
      DateTime.utc(2026, 10, 20, 5),
    );
    expect(
      AppointmentSchedule.scheduledUtc(DateTime(2026, 10, 20), '3:30 PM'),
      DateTime.utc(2026, 10, 20, 7, 30),
    );
  });

  test(
    'Past days, Sundays, elapsed slots, and closing time are unavailable',
    () {
      expect(
        AppointmentSchedule.isDateSelectable(DateTime(2026, 10, 18), now),
        isFalse,
      );
      expect(
        AppointmentSchedule.isDateSelectable(DateTime(2026, 10, 25), now),
        isFalse,
      );
      expect(
        AppointmentSchedule.isSlotSelectable(
          DateTime(2026, 10, 19),
          '9:00 AM',
          DateTime.utc(2026, 10, 19, 2),
        ),
        isFalse,
      );
      expect(
        AppointmentSchedule.isSlotSelectable(
          DateTime(2026, 10, 19),
          '4:00 PM',
          now,
        ),
        isFalse,
      );
      expect(
        AppointmentSchedule.isSlotSelectable(
          DateTime(2026, 10, 24),
          '3:30 PM',
          now,
        ),
        isTrue,
      );
    },
  );

  test('After Saturday closing the initial calendar date becomes Monday', () {
    expect(
      AppointmentSchedule.firstBookableDate(DateTime.utc(2026, 10, 17, 9)),
      DateTime.utc(2026, 10, 19),
    );
  });

  test('Manila date boundary is independent of the device timezone', () {
    final wall = AppointmentSchedule.inManila(
      DateTime.utc(2026, 10, 19, 23, 30),
    );
    expect(wall.day, 20);
    expect(AppointmentSchedule.formatTime(wall), '7:30 AM');
  });

  test('Only exact future offered slots pass service validation', () {
    expect(
      () => AppointmentSchedule.validateInstant(
        DateTime.utc(2026, 10, 20, 1),
        now,
      ),
      returnsNormally,
    );
    expect(
      () => AppointmentSchedule.validateInstant(
        DateTime.utc(2026, 10, 20, 1, 1),
        now,
      ),
      throwsArgumentError,
    );
    expect(
      () => AppointmentSchedule.validateInstant(
        DateTime.utc(2026, 10, 25, 1),
        now,
      ),
      throwsArgumentError,
    );
    expect(
      () => AppointmentSchedule.scheduledUtc(DateTime(2026, 10, 20), 'invalid'),
      throwsArgumentError,
    );
  });
}
