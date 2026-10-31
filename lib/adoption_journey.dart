/// The adoption "Progress Road": five stages an adopter moves through.
///
/// The database has no stage column, so the stage is derived from what the
/// admin web app already records: the application status, the pet's status,
/// and the adopter's meet & greet appointment for that pet.
enum JourneyStage {
  submitted('Application Submitted', 'Submitted'),
  reviewing('Reviewing Details', 'Reviewing'),
  interview('Scheduling Interview', 'Interview'),
  meetAndGreet('Meet & Greet', 'Meet & Greet'),
  welcomeHome('Welcome Home!', 'Home');

  const JourneyStage(this.title, this.shortTitle);

  final String title;
  final String shortTitle;
}

class AdoptionJourney {
  final String applicationId;
  final String petId;
  final String petName;
  final String petImage;
  final String shelterId;
  final JourneyStage stage;

  /// Rejected or withdrawn: the road stops at [stage] and does not continue.
  final bool halted;
  final String applicationStatus;

  /// The meet & greet appointment shaping stages 3-4, if any.
  final DateTime? meetAndGreetAt;
  final String? meetAndGreetStatus;
  final DateTime? submittedAt;

  /// When the journey ended: pet marked adopted, or application closed.
  final DateTime? finishedAt;

  const AdoptionJourney({
    required this.applicationId,
    required this.petId,
    required this.petName,
    required this.petImage,
    required this.shelterId,
    required this.stage,
    required this.halted,
    required this.applicationStatus,
    this.meetAndGreetAt,
    this.meetAndGreetStatus,
    this.submittedAt,
    this.finishedAt,
  });

  bool get isComplete => stage == JourneyStage.welcomeHome && !halted;

  /// Still moving through the road (not adopted, rejected or withdrawn).
  bool get isActive => !halted && !isComplete;

  /// The status word every screen shows for this application.
  String get statusLabel {
    if (isComplete) return 'Successful';
    if (!halted) return stage.title;
    return applicationStatus == 'withdrawn' ? 'Withdrawn' : 'Rejected';
  }

  /// One line telling the adopter where they stand right now.
  String get caption {
    if (halted) {
      return applicationStatus == 'withdrawn'
          ? 'You withdrew this application.'
          : 'The shelter could not move forward with this application. '
                'You can still apply for another pet.';
    }
    switch (stage) {
      case JourneyStage.submitted:
        return 'JALRG received your application for $petName.';
      case JourneyStage.reviewing:
        return 'Volunteers are reviewing your details.';
      case JourneyStage.interview:
        return meetAndGreetStatus == 'pending'
            ? 'Meet & greet requested. Waiting for the shelter to confirm.'
            : 'Approved! Book a meet & greet to schedule your interview.';
      case JourneyStage.meetAndGreet:
        return meetAndGreetStatus == 'completed'
            ? 'Meet & greet done. Final paperwork is on its way.'
            : 'Your meet & greet with $petName is confirmed.';
      case JourneyStage.welcomeHome:
        return '$petName is officially part of your family! '
            'Share their new life in Success Stories.';
    }
  }

  /// Show the "Book Meet & Greet" action: approved, nothing booked yet.
  bool get needsMeetAndGreet =>
      !halted &&
      stage == JourneyStage.interview &&
      meetAndGreetStatus == null &&
      shelterId.isNotEmpty;

  /// Builds a journey from an `adoption_applications` row (with nested
  /// `pets`) and the adopter's raw `appointments` rows.
  factory AdoptionJourney.fromRows(
    Map<String, dynamic> application,
    List<Map<String, dynamic>> appointments,
  ) {
    final pet = application['pets'] as Map<String, dynamic>? ?? const {};
    final shelter = pet['shelters'] as Map<String, dynamic>?;
    final petId = (application['pet_id'] ?? pet['id'] ?? '').toString();
    final status = (application['status'] ?? 'pending')
        .toString()
        .toLowerCase();
    final petStatus = (pet['status'] ?? '').toString().toLowerCase();

    final meet = _latestMeetAndGreet(petId, appointments);
    final meetStatus = meet?['status']?.toString().toLowerCase();

    var halted = false;
    JourneyStage stage;
    switch (status) {
      case 'approved':
        if (petStatus == 'adopted') {
          stage = JourneyStage.welcomeHome;
        } else if (meetStatus == 'confirmed' || meetStatus == 'completed') {
          stage = JourneyStage.meetAndGreet;
        } else {
          stage = JourneyStage.interview;
        }
      case 'under_review':
        stage = JourneyStage.reviewing;
      case 'rejected':
        stage = JourneyStage.reviewing;
        halted = true;
      case 'withdrawn':
        stage = JourneyStage.submitted;
        halted = true;
      default:
        stage = JourneyStage.submitted;
    }

    return AdoptionJourney(
      applicationId: application['id']?.toString() ?? '',
      petId: petId,
      petName: pet['name']?.toString() ?? 'your pet',
      petImage: pet['image_url']?.toString() ?? '',
      shelterId: (pet['shelter_id'] ?? shelter?['id'] ?? '').toString(),
      stage: stage,
      halted: halted,
      applicationStatus: status,
      meetAndGreetAt: DateTime.tryParse(meet?['scheduled_at']?.toString() ?? ''),
      // Only meaningful once approved; earlier stages ignore the visit.
      meetAndGreetStatus: status == 'approved' ? meetStatus : null,
      submittedAt: DateTime.tryParse(
        application['created_at']?.toString() ?? '',
      ),
      finishedAt: stage == JourneyStage.welcomeHome && !halted
          // No adopted_at column: the pet's last update is when staff
          // marked it adopted.
          ? _date(pet['updated_at']) ?? _date(application['decided_at'])
          : halted
          ? _date(application['decided_at']) ?? _date(application['updated_at'])
          : null,
    );
  }

  static DateTime? _date(dynamic value) =>
      value == null ? null : DateTime.tryParse(value.toString());

  /// The most relevant meet & greet for this pet: a live booking
  /// (pending/confirmed/completed) beats a cancelled one, newest first.
  static Map<String, dynamic>? _latestMeetAndGreet(
    String petId,
    List<Map<String, dynamic>> appointments,
  ) {
    if (petId.isEmpty) return null;
    final matches = appointments.where((a) {
      final status = a['status']?.toString().toLowerCase();
      return a['pet_id']?.toString() == petId &&
          a['appointment_type'] == 'meet_and_greet' &&
          status != 'cancelled' &&
          status != 'rejected';
    }).toList();
    if (matches.isEmpty) return null;
    const rank = {'completed': 2, 'confirmed': 1};
    matches.sort((a, b) {
      final byRank = (rank[b['status']] ?? 0).compareTo(rank[a['status']] ?? 0);
      if (byRank != 0) return byRank;
      return (b['scheduled_at'] ?? '').toString().compareTo(
        (a['scheduled_at'] ?? '').toString(),
      );
    });
    return matches.first;
  }
}

/// Which journeys sit on the live tracker and which move to history.
///
/// Adoptions in progress are tracked. A finished one (adopted, rejected or
/// withdrawn) stays on the tracker only while nothing else is in progress,
/// or while its celebration is still due; otherwise it moves to history.
class JourneyBoard {
  final List<AdoptionJourney> tracked;
  final List<AdoptionJourney> history;

  const JourneyBoard._(this.tracked, this.history);

  factory JourneyBoard.of(
    List<AdoptionJourney> all, {
    Set<String> celebrating = const {},
  }) {
    final tracked = all
        .where((j) => j.isActive || celebrating.contains(j.applicationId))
        .toList();
    final finished = all.where((j) => !tracked.contains(j)).toList()
      ..sort((a, b) => _endOf(b).compareTo(_endOf(a)));
    if (tracked.isEmpty && finished.isNotEmpty) {
      // Nothing new yet: keep the latest outcome (ideally the adoption)
      // in the spotlight.
      final latest = finished.firstWhere(
        (j) => j.isComplete,
        orElse: () => finished.first,
      );
      tracked.add(latest);
      finished.remove(latest);
    }
    return JourneyBoard._(tracked, finished);
  }

  static DateTime _endOf(AdoptionJourney j) =>
      j.finishedAt ?? j.submittedAt ?? DateTime(0);
}
