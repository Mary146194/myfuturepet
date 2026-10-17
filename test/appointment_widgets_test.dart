import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfuturepet/appointment_store.dart';
import 'package:myfuturepet/screens/my_appointments_screen.dart';
import 'package:myfuturepet/screens/visit_appointment_screen.dart';
import 'package:myfuturepet/services/appointment_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FixtureAppointmentService extends AppointmentService {
  FixtureAppointmentService(SupabaseClient client) : super(client: client);
  late Future<Map<String, dynamic>> Function() book;
  late Future<List<Map<String, dynamic>>> Function() fetch;
  DateTime? requestedTime;
  String? requestedShelter;
  int bookingCalls = 0;
  int fetchCalls = 0;

  @override
  Future<Map<String, dynamic>> bookAppointment({
    required String shelterId,
    String? petId,
    required DateTime scheduledAt,
    String appointmentType = 'shelter_visit',
    String? notes,
  }) {
    bookingCalls++;
    requestedTime = scheduledAt;
    requestedShelter = shelterId;
    return book();
  }

  @override
  Future<List<Map<String, dynamic>>> fetchMyAppointments({
    bool throwOnError = false,
  }) {
    fetchCalls++;
    return fetch();
  }
}

void main() {
  late SupabaseClient client;
  late FixtureAppointmentService service;
  final row = <String, dynamic>{
    'id': 'appointment-1',
    'scheduled_at': '2026-10-20T05:00:00Z',
    'status': 'pending',
    'appointment_type': 'shelter_visit',
    'shelters': {'name': 'Jagna Animal Lover and Rescue Group'},
    'pets': {'id': 'pet-1', 'name': 'Test pet', 'image_url': ''},
  };

  setUp(() {
    client = SupabaseClient('http://localhost', 'local-test-key');
    service = FixtureAppointmentService(client);
    service.book = () async => Map.of(row);
    service.fetch = () async => [Map.of(row)];
    AppointmentStore.clearAppointments();
  });
  tearDown(() async {
    await client.dispose();
    AppointmentStore.clearAppointments();
  });

  void mobileSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(430, 950);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> openBooking(WidgetTester tester, {DateTime? now}) async {
    mobileSize(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: VisitAppointmentScreen(
          pet: const {
            'id': 'pet-1',
            'name': 'Test pet',
            'shelter_id': 'live-shelter-id',
            'shelter': 'Jagna Animal Lover and Rescue Group',
          },
          appointmentService: service,
          now: () => now ?? DateTime.utc(2026, 10, 20),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> pickAndSubmit(WidgetTester tester) async {
    await tester.ensureVisible(find.byKey(const ValueKey('slot-1:00 PM')));
    await tester.tap(find.byKey(const ValueKey('slot-1:00 PM')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Request Appointment'));
    await tester.tap(find.text('Request Appointment'));
    await tester.pump();
  }

  testWidgets('Waits for server acceptance and shows a pending visit request', (
    tester,
  ) async {
    await openBooking(tester);
    final pending = Completer<Map<String, dynamic>>();
    service.book = () => pending.future;
    await pickAndSubmit(tester);
    expect(service.bookingCalls, 1);
    expect(service.requestedTime, DateTime.utc(2026, 10, 20, 5));
    expect(service.requestedShelter, 'live-shelter-id');
    expect(find.text('Sending...'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    expect(AppointmentStore.appointments, isEmpty);
    expect(
      tester.widget<PopScope>(find.byType(PopScope).first).canPop,
      isFalse,
    );
    pending.complete(Map.of(row));
    await tester.pumpAndSettle();
    expect(find.text('Visit Request Sent'), findsOneWidget);
    expect(find.textContaining('pending shelter approval'), findsOneWidget);
    expect(AppointmentStore.appointments.single['status'], 'Pending');
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Booking failure keeps the request editable and never shows success',
    (tester) async {
      await openBooking(tester);
      service.book = () async => throw Exception('offline');
      await pickAndSubmit(tester);
      await tester.pumpAndSettle();
      expect(find.text('Visit Request Sent'), findsNothing);
      expect(
        find.textContaining('Could not request your visit.'),
        findsOneWidget,
      );
      expect(find.text('Request Appointment'), findsOneWidget);
      expect(AppointmentStore.appointments, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Calendar excludes Sunday and disables elapsed same-day slots', (
    tester,
  ) async {
    await openBooking(
      tester,
      now: DateTime.utc(2026, 10, 19, 2),
    ); // Monday 10 AM
    expect(
      tester
          .widget<GestureDetector>(
            find.byKey(const ValueKey('date-2026-10-25')),
          )
          .onTap,
      isNull,
    );
    expect(
      tester
          .widget<GestureDetector>(
            find.byKey(const ValueKey('date-2026-10-18')),
          )
          .onTap,
      isNull,
    );
    expect(
      tester
          .widget<GestureDetector>(find.byKey(const ValueKey('slot-9:00 AM')))
          .onTap,
      isNull,
    );
    expect(
      tester
          .widget<GestureDetector>(find.byKey(const ValueKey('slot-10:30 AM')))
          .onTap,
      isNotNull,
    );
    expect(find.text('Interview'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'My Appointments loads server bookings and refreshes their status',
    (tester) async {
      mobileSize(tester);
      final pending = Completer<List<Map<String, dynamic>>>();
      service.fetch = () => pending.future;
      await tester.pumpWidget(
        MaterialApp(home: MyAppointmentsScreen(appointmentService: service)),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      pending.complete([Map.of(row)]);
      await tester.pumpAndSettle();
      expect(find.text('Test pet'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('1:00 PM'), findsOneWidget);
      service.fetch = () async => [
        {...row, 'status': 'confirmed'},
      ];
      await tester.tap(find.byTooltip('Refresh appointments'));
      await tester.pumpAndSettle();
      expect(service.fetchCalls, 2);
      expect(find.text('Confirmed'), findsOneWidget);
      expect(find.text('Pending'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'My Appointments offers retry on errors and clears stale empty results',
    (tester) async {
      mobileSize(tester);
      AppointmentStore.appointments.add({'id': 'stale'});
      service.fetch = () async => throw Exception('offline');
      await tester.pumpWidget(
        MaterialApp(home: MyAppointmentsScreen(appointmentService: service)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('No Appointments Yet'), findsNothing);
      service.fetch = () async => [];
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.text('No Appointments Yet'), findsOneWidget);
      expect(AppointmentStore.appointments, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'Changing the calendar date clears the old time and books the new selection',
    (tester) async {
      await openBooking(tester);
      await tester.ensureVisible(find.byKey(const ValueKey('slot-1:00 PM')));
      await tester.tap(find.byKey(const ValueKey('slot-1:00 PM')));
      await tester.pumpAndSettle();
      final newDate = find.byKey(const ValueKey('date-2026-10-22'));
      await tester.ensureVisible(newDate);
      await tester.tap(newDate);
      await tester.pumpAndSettle();
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNull,
      );
      final newTime = find.byKey(const ValueKey('slot-10:30 AM'));
      await tester.ensureVisible(newTime);
      await tester.tap(newTime);
      await tester.pumpAndSettle();
      service.book = () async => {
        ...row,
        'scheduled_at': service.requestedTime!.toIso8601String(),
      };
      await tester.ensureVisible(find.text('Request Appointment'));
      await tester.tap(find.text('Request Appointment'));
      await tester.pumpAndSettle();
      expect(service.requestedTime, DateTime.utc(2026, 10, 22, 2, 30));
      expect(AppointmentStore.appointments.single['date'], '2026-10-22');
      expect(AppointmentStore.appointments.single['time'], '10:30 AM');
      expect(tester.takeException(), isNull);
    },
  );
}
