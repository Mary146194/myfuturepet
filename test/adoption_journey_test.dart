import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfuturepet/adoption_application_store.dart';
import 'package:myfuturepet/adoption_journey.dart';
import 'package:myfuturepet/appointment_store.dart';
import 'package:myfuturepet/screens/my_applications_screen.dart';
import 'package:myfuturepet/screens/my_appointments_screen.dart';
import 'package:myfuturepet/services/adoption_journey_service.dart';
import 'package:myfuturepet/services/appointment_service.dart';
import 'package:myfuturepet/widgets/adoption_journey_tracker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _RowsAppointmentService extends AppointmentService {
  _RowsAppointmentService(SupabaseClient client, this.rows)
    : super(client: client);
  final List<Map<String, dynamic>> rows;

  @override
  Future<List<Map<String, dynamic>>> fetchMyAppointments({
    bool throwOnError = false,
  }) async => rows;
}

Map<String, dynamic> application({
  String id = 'app-1',
  String status = 'pending',
  String petStatus = 'available',
}) => {
  'id': id,
  'pet_id': 'pet-1',
  'status': status,
  'created_at': '2026-10-01T02:00:00Z',
  'pets': {
    'id': 'pet-1',
    'name': 'Bantay',
    'image_url': '',
    'status': petStatus,
    'shelters': {'id': 'shelter-1', 'name': 'JALRG'},
  },
};

Map<String, dynamic> meet(String status, {String petId = 'pet-1'}) => {
  'id': 'appt-$status',
  'pet_id': petId,
  'appointment_type': 'meet_and_greet',
  'status': status,
  'scheduled_at': '2026-11-05T02:00:00Z',
};

void main() {
  setUpAll(() {
    // Fixture meet & greets are on 2026-11-05.
    AppointmentStore.clock = () => DateTime.utc(2026, 10, 31);
    _sharedClient = SupabaseClient('http://localhost', 'local-test-key');
    _sharedClientReady = true;
  });
  tearDownAll(() async => _sharedClient.dispose());

  group('AdoptionJourney stage', () {
    JourneyStage stageOf(
      Map<String, dynamic> app, [
      List<Map<String, dynamic>> appts = const [],
    ]) => AdoptionJourney.fromRows(app, appts).stage;

    test('maps application status to the first three stages', () {
      expect(stageOf(application()), JourneyStage.submitted);
      expect(
        stageOf(application(status: 'under_review')),
        JourneyStage.reviewing,
      );
      expect(stageOf(application(status: 'approved')), JourneyStage.interview);
    });

    test('a pending meet & greet keeps the adopter scheduling', () {
      final j = AdoptionJourney.fromRows(application(status: 'approved'), [
        meet('pending'),
      ]);
      expect(j.stage, JourneyStage.interview);
      expect(j.needsMeetAndGreet, isFalse);
      expect(j.caption, contains('Waiting for the shelter'));
    });

    test('a confirmed or completed meet & greet reaches stage 4', () {
      for (final s in ['confirmed', 'completed']) {
        expect(
          stageOf(application(status: 'approved'), [meet(s)]),
          JourneyStage.meetAndGreet,
        );
      }
    });

    test('cancelled visits and other pets do not count', () {
      final j = AdoptionJourney.fromRows(application(status: 'approved'), [
        meet('cancelled'),
        meet('confirmed', petId: 'pet-2'),
      ]);
      expect(j.stage, JourneyStage.interview);
      expect(j.needsMeetAndGreet, isTrue);
    });

    test('meet & greet before approval does not skip review', () {
      expect(
        stageOf(application(status: 'under_review'), [meet('confirmed')]),
        JourneyStage.reviewing,
      );
    });

    test('pet marked adopted completes the journey', () {
      final j = AdoptionJourney.fromRows(
        application(status: 'approved', petStatus: 'adopted'),
        const [],
      );
      expect(j.stage, JourneyStage.welcomeHome);
      expect(j.isComplete, isTrue);
    });

    test('rejected and withdrawn applications halt the road', () {
      final rejected = AdoptionJourney.fromRows(
        application(status: 'rejected'),
        const [],
      );
      expect(rejected.halted, isTrue);
      expect(rejected.stage, JourneyStage.reviewing);
      final withdrawn = AdoptionJourney.fromRows(
        application(status: 'withdrawn'),
        const [],
      );
      expect(withdrawn.halted, isTrue);
      expect(withdrawn.caption, contains('withdrew'));
    });

    test('reads the shelter id for booking from the nested shelter', () {
      final j = AdoptionJourney.fromRows(
        application(status: 'approved'),
        const [],
      );
      expect(j.shelterId, 'shelter-1');
    });
  });

  group('AdoptionJourneyService', () {
    late List<Map<String, dynamic>> apps;
    late List<Map<String, dynamic>> appts;
    late List<String> pushes;
    late AdoptionJourneyService service;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      apps = [application()];
      appts = [];
      pushes = [];
      service = AdoptionJourneyService.test(
        fetchApplications: () async => apps,
        fetchAppointments: () async => appts,
        notify: (journey, title, body) async => pushes.add(body),
      );
    });

    test('first sight sets a baseline without celebrating', () async {
      await service.init();
      expect(service.journeys.value.single.stage, JourneyStage.submitted);
      expect(service.celebrations.value, isEmpty);
      expect(pushes, isEmpty);
    });

    test('an advance pushes once and celebrates until marked', () async {
      await service.init();
      apps = [application(status: 'under_review')];
      await service.refresh();
      expect(service.celebrations.value, {'app-1'});
      expect(pushes.single, startsWith('Reviewing Details'));

      await service.refresh();
      expect(pushes, hasLength(1), reason: 'no duplicate push');

      await service.markCelebrated('app-1');
      await service.refresh();
      expect(service.celebrations.value, isEmpty);
    });

    test('halted applications never celebrate', () async {
      await service.init();
      apps = [application(status: 'rejected')];
      await service.refresh();
      expect(service.celebrations.value, isEmpty);
      expect(pushes, isEmpty);
    });

    test('a failed fetch keeps the last known road', () async {
      var fail = false;
      service = AdoptionJourneyService.test(
        fetchApplications: () async {
          if (fail) throw Exception('offline');
          return apps;
        },
        fetchAppointments: () async => appts,
        notify: (_, _, _) async {},
      );
      await service.init();
      fail = true;
      await service.refresh();
      expect(service.journeys.value, hasLength(1));
    });
  });

  group('AdoptionJourneyTracker', () {
    Widget host(Widget child) => MaterialApp(
      home: Scaffold(
        body: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    );

    testWidgets('shows all five stages and the current step', (tester) async {
      final journey = AdoptionJourney.fromRows(
        application(status: 'under_review'),
        const [],
      );
      await tester.pumpWidget(
        host(AdoptionJourneyTracker(journey: journey, isDark: false)),
      );
      for (final s in JourneyStage.values) {
        expect(find.text(s.shortTitle), findsOneWidget);
      }
      expect(find.text('Step 2 of 5'), findsOneWidget);
      expect(find.text('Book Meet & Greet'), findsNothing);
    });

    testWidgets('offers booking once approved', (tester) async {
      var booked = false;
      final journey = AdoptionJourney.fromRows(
        application(status: 'approved'),
        const [],
      );
      await tester.pumpWidget(
        host(
          AdoptionJourneyTracker(
            journey: journey,
            isDark: false,
            onBookMeetAndGreet: () => booked = true,
          ),
        ),
      );
      await tester.tap(find.text('Book Meet & Greet'));
      expect(booked, isTrue);
    });

    testWidgets('celebration plays then reports back', (tester) async {
      var celebrated = false;
      final journey = AdoptionJourney.fromRows(
        application(status: 'approved', petStatus: 'adopted'),
        const [],
      );
      await tester.pumpWidget(
        host(
          AdoptionJourneyTracker(
            journey: journey,
            isDark: true,
            celebrate: true,
            onCelebrated: () => celebrated = true,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1400));
      expect(find.text('New milestone unlocked!'), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(celebrated, isTrue);
      expect(find.text('Successful'), findsOneWidget);
    });
  });

  group('Journey is shared across screens', () {
    late SupabaseClient client;
    // Created outside the widget test zone, like appointment_widgets_test.
    setUp(() => client = SupabaseClient('http://localhost', 'local-test-key'));
    tearDown(() async {
      await client.dispose();
      AdoptionJourneyService().journeys.value = [];
      AdoptionApplicationStore.clear();
      AppointmentStore.clear();
    });

    test('status label matches the road on every screen', () {
      expect(
        AdoptionJourney.fromRows(application(status: 'approved'), [
          meet('confirmed'),
        ]).statusLabel,
        'Meet & Greet',
      );
      expect(
        AdoptionJourney.fromRows(
          application(status: 'rejected'),
          const [],
        ).statusLabel,
        'Rejected',
      );
    });

    test('a journey refresh feeds both stores from the same rows', () async {
      SharedPreferences.setMockInitialValues({});
      final service = AdoptionJourneyService.test(
        fetchApplications: () async => [application(status: 'approved')],
        fetchAppointments: () async => [meet('confirmed')],
        notify: (_, _, _) async {},
      );
      await service.init();
      final app = AdoptionApplicationStore.applications.single;
      expect(app['id'], 'app-1');
      expect((app['pet'] as Map)['shelter_id'], 'shelter-1');
      final appt = AppointmentStore.appointments.single;
      expect(appt['status'], 'Confirmed');
      expect(appt['appointmentType'], 'Meet and Greet');
    });

    testWidgets('My Applications shows the journey stage, not raw status', (
      tester,
    ) async {
      final row = application(status: 'approved');
      AdoptionApplicationStore.applyRows([row]);
      AdoptionJourneyService().journeys.value = [
        AdoptionJourney.fromRows(row, const []),
      ];
      await tester.pumpWidget(const MaterialApp(home: MyApplicationsScreen()));
      await tester.pump();
      expect(find.text('Scheduling Interview'), findsOneWidget);
      expect(find.text('Book Meet & Greet'), findsOneWidget);
      expect(find.text('Book Visit'), findsNothing);
      expect(find.text('Approved'), findsNothing);

      // Realtime moves the journey; the open screen follows.
      AdoptionJourneyService().journeys.value = [
        AdoptionJourney.fromRows(row, [meet('confirmed')]),
      ];
      await tester.pump();
      expect(find.text('Meet & Greet'), findsWidgets);
      expect(find.text('Book Meet & Greet'), findsNothing);
    });

    testWidgets('Application details shows the road and current stage', (
      tester,
    ) async {
      final row = application(status: 'under_review');
      AdoptionApplicationStore.applyRows([row]);
      AdoptionJourneyService().journeys.value = [
        AdoptionJourney.fromRows(row, const []),
      ];
      await tester.pumpWidget(
        MaterialApp(
          home: ApplicationDetailsScreen(
            application: AdoptionApplicationStore.applications.single,
          ),
        ),
      );
      await tester.pump();
      // Header badge and journey card agree.
      expect(find.text('Reviewing Details'), findsNWidgets(2));
      expect(find.text('Volunteers are reviewing your details.'), findsOneWidget);
      expect(find.textContaining('currently under review'), findsNothing);
    });

    testWidgets('My Appointments links a meet & greet to its journey', (
      tester,
    ) async {
      final row = application(status: 'approved');
      final service = _RowsAppointmentService(client, [
        {
          ...meet('confirmed'),
          'pets': {'id': 'pet-1', 'name': 'Bantay'},
        },
      ]);
      AdoptionJourneyService().journeys.value = [
        AdoptionJourney.fromRows(row, [meet('confirmed')]),
      ];
      await tester.pumpWidget(
        MaterialApp(home: MyAppointmentsScreen(appointmentService: service)),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('Adoption journey · Step 4 of 5: Meet & Greet'),
        findsOneWidget,
      );
    });
  });

  group('Adoption history', () {
    AdoptionJourney journeyOf(
      String id,
      String status, {
      String petStatus = 'available',
      String created = '2026-10-01T02:00:00Z',
      String? petUpdated,
    }) {
      final row = application(id: id, status: status, petStatus: petStatus);
      row['created_at'] = created;
      if (petUpdated != null) {
        (row['pets'] as Map<String, dynamic>)['updated_at'] = petUpdated;
      }
      return AdoptionJourney.fromRows(row, const []);
    }

    test('a lone finished adoption stays on the tracker', () {
      final adopted = journeyOf('a', 'approved', petStatus: 'adopted');
      final board = JourneyBoard.of([adopted]);
      expect(board.tracked.single.applicationId, 'a');
      expect(board.history, isEmpty);
    });

    test('a new application moves the finished adoption to history', () {
      final adopted = journeyOf(
        'a',
        'approved',
        petStatus: 'adopted',
        petUpdated: '2026-10-20T04:00:00Z',
      );
      final fresh = journeyOf('b', 'pending', created: '2026-10-25T02:00:00Z');
      final board = JourneyBoard.of([adopted, fresh]);
      expect(board.tracked.map((j) => j.applicationId), ['b']);
      expect(board.history.single.applicationId, 'a');
      expect(board.history.single.statusLabel, 'Successful');
      expect(board.history.single.finishedAt, DateTime.utc(2026, 10, 20, 4));
    });

    test('an adoption still celebrating stays tracked until it plays', () {
      final adopted = journeyOf('a', 'approved', petStatus: 'adopted');
      final fresh = journeyOf('b', 'under_review');
      final board = JourneyBoard.of([adopted, fresh], celebrating: {'a'});
      expect(board.tracked.map((j) => j.applicationId), containsAll(['a', 'b']));
      expect(board.history, isEmpty);
    });

    test('closed applications go to history behind the adoption', () {
      final adopted = journeyOf('a', 'approved', petStatus: 'adopted');
      final rejected = journeyOf('r', 'rejected');
      final board = JourneyBoard.of([rejected, adopted]);
      expect(board.tracked.single.applicationId, 'a');
      expect(board.history.single.applicationId, 'r');
    });

    testWidgets('My Applications lists finished adoptions under history', (
      tester,
    ) async {
      final adoptedRow = application(
        id: 'a',
        status: 'approved',
        petStatus: 'adopted',
      );
      final freshRow = application(id: 'b', status: 'under_review');
      AdoptionApplicationStore.applyRows([adoptedRow, freshRow]);
      AdoptionJourneyService().journeys.value = [
        AdoptionJourney.fromRows(adoptedRow, const []),
        AdoptionJourney.fromRows(freshRow, const []),
      ];
      addTearDown(() {
        AdoptionJourneyService().journeys.value = [];
        AdoptionApplicationStore.clear();
      });
      await tester.pumpWidget(const MaterialApp(home: MyApplicationsScreen()));
      await tester.pump();
      expect(find.text('Application History'), findsOneWidget);
      expect(find.text('Successful'), findsOneWidget);
      expect(find.text('1 in progress • 1 done'), findsOneWidget);
      // Only the in-progress application keeps a live road.
      expect(find.text('Volunteers are reviewing your details.'), findsOneWidget);
      expect(find.textContaining('officially part of your family'), findsNothing);
    });
  });

  group('Done items leave the active counts', () {
    tearDown(() {
      AdoptionJourneyService().journeys.value = [];
      AdoptionApplicationStore.clear();
      AppointmentStore.clear();
    });

    test('finished applications are not counted as active', () {
      AdoptionApplicationStore.applyRows([
        application(id: 'a', status: 'approved', petStatus: 'adopted'),
        application(id: 'r', status: 'rejected'),
        application(id: 'p', status: 'under_review'),
      ]);
      expect(AdoptionApplicationStore.activeCount, 1);
      AdoptionApplicationStore.applyRows([
        application(id: 'a', status: 'approved', petStatus: 'adopted'),
      ]);
      expect(AdoptionApplicationStore.activeCount, 0);
    });

    test('past visits move to history on their own', () {
      AppointmentStore.applyRows([
        {...meet('confirmed'), 'scheduled_at': '2026-10-30T02:00:00Z'},
        {...meet('pending'), 'scheduled_at': '2026-10-29T02:00:00Z'},
        // Started 30 minutes ago: still in progress, not history yet.
        {...meet('confirmed'), 'scheduled_at': '2026-10-30T23:30:00Z'},
      ]);
      expect(AppointmentStore.activeCount, 1);
      expect(
        AppointmentStore.historyAppointments.map(AppointmentStore.doneLabel),
        ['Done', 'Expired'],
      );
    });

    test('completed and cancelled appointments move to history', () {
      AppointmentStore.applyRows([
        meet('completed'),
        meet('cancelled'),
        meet('confirmed'),
      ]);
      expect(AppointmentStore.activeCount, 1);
      expect(
        AppointmentStore.historyAppointments.map(AppointmentStore.doneLabel),
        containsAll(['Done', 'Cancelled']),
      );
    });

    testWidgets('My Appointments shows an Appointment History', (
      tester,
    ) async {
      final client = _testClient();
      final service = _RowsAppointmentService(client, [
        {
          ...meet('completed'),
          'pets': {'id': 'pet-1', 'name': 'Bantay'},
        },
      ]);
      await tester.pumpWidget(
        MaterialApp(home: MyAppointmentsScreen(appointmentService: service)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Appointment History'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
      expect(find.textContaining('No upcoming appointments'), findsOneWidget);
      expect(find.textContaining('0 upcoming • 1 done'), findsOneWidget);
    });
  });
}

// Created outside the widget-test zone (setUpAll) so its auth timer is real.
late SupabaseClient _sharedClient;
bool _sharedClientReady = false;
SupabaseClient _testClient() {
  if (!_sharedClientReady) {
    throw StateError('call _setUpSharedClient in setUpAll');
  }
  return _sharedClient;
}
