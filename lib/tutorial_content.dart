import 'package:flutter/material.dart';

/// A small picture of the exact control a step talks about, drawn with the
/// app's own icons and colors so users recognise it on screen.
sealed class TutorialVisual {
  const TutorialVisual();
}

/// A filled button, e.g. "Adopt Me".
class ButtonVisual extends TutorialVisual {
  final String label;
  final IconData? icon;
  final Color color;
  const ButtonVisual(this.label, {this.icon, this.color = brandColor});
}

/// Several outlined buttons or chips side by side; [selected] is highlighted.
class ChipsVisual extends TutorialVisual {
  final List<String> labels;
  final int? selected;
  final List<IconData>? icons;
  const ChipsVisual(this.labels, {this.selected, this.icons});
}

/// Text boxes as they appear in a form.
class FieldsVisual extends TutorialVisual {
  final List<(IconData, String)> fields;
  const FieldsVisual(this.fields);
}

/// The bottom navigation bar with one tab highlighted.
class TabsVisual extends TutorialVisual {
  final int highlight;
  const TabsVisual(this.highlight);
}

/// Round icon buttons with a caption under each.
class IconsVisual extends TutorialVisual {
  final List<(IconData, String)> icons;
  const IconsVisual(this.icons);
}

/// A numbered row of stages, e.g. the adoption journey.
class StagesVisual extends TutorialVisual {
  final List<String> stages;
  const StagesVisual(this.stages);
}

/// A gesture hint: an icon with a short caption ("Drag to turn").
class GestureVisual extends TutorialVisual {
  final IconData icon;
  final String caption;
  const GestureVisual(this.icon, this.caption);
}

class TutorialStep {
  final String title;
  final String body;
  final TutorialVisual? visual;

  const TutorialStep(this.title, this.body, [this.visual]);
}

class TutorialSection {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  /// Where the feature lives, e.g. "Profile tab → Edit Profile".
  final String whereToFind;
  final List<TutorialStep> steps;
  final List<String> tips;

  /// Optional icon glossary shown under the steps.
  final List<(IconData, String)> iconGuide;

  const TutorialSection({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.whereToFind,
    required this.steps,
    this.tips = const [],
    this.iconGuide = const [],
  });
}

const Color brandColor = Color(0xFFA94327);
const Color tealColor = Color(0xFF008F82);

/// The "How to Use" guide. Labels match the buttons in the app exactly.
const List<TutorialSection> tutorialSections = [
  TutorialSection(
    id: 'getting-started',
    title: 'Getting Started',
    subtitle: 'Register, log in and manage your profile',
    icon: Icons.rocket_launch_rounded,
    color: brandColor,
    whereToFind:
        'The Welcome screen when you open the app, and the Profile tab',
    steps: [
      TutorialStep(
        'Create your account',
        'On the Welcome screen, tap Register. Fill in your Full Name, '
            'Email Address and a Password of at least 6 characters, then '
            'type the password again in Confirm Password.',
        FieldsVisual([
          (Icons.person_outline, 'Full Name'),
          (Icons.email_outlined, 'Email Address'),
          (Icons.lock_outline, 'Password'),
          (Icons.lock_outline, 'Confirm Password'),
        ]),
      ),
      TutorialStep(
        'Agree and register',
        'Tick "I agree to the Terms of Service and Privacy Policy", then tap '
            'Register. If the app asks you to verify, open the email we sent '
            'you and tap the link.',
        ButtonVisual('Register'),
      ),
      TutorialStep(
        'Log in',
        'Enter your Email Address and Password and tap Login. You can also '
            'tap Sign in with Google to use your Google account.',
        ChipsVisual(
          ['Login', 'Sign in with Google'],
          selected: 0,
          icons: [Icons.login_rounded, Icons.g_mobiledata_rounded],
        ),
      ),
      TutorialStep(
        'Forgot your password?',
        'Type your email on the Login screen, then tap Forgot Password?. A '
            'reset link is sent to your inbox.',
        ChipsVisual(['Forgot Password?']),
      ),
      TutorialStep(
        'Meet your matches first',
        'The first time you log in, Pet Matcher asks 7 quick questions about '
            'your home and lifestyle, then shows the rescues that suit you '
            'best. Tap Skip if you want to go straight to Home.',
        ChipsVisual(
          ['A dog', 'A cat', 'Surprise me'],
          selected: 0,
          icons: [Icons.pets, Icons.pets, Icons.auto_awesome],
        ),
      ),
      TutorialStep(
        'Edit your profile',
        'Open the Profile tab and tap Edit Profile. Tap your picture to change '
            'the photo, update your Name, then tap Save.',
        ChipsVisual(
          ['Edit Profile', 'Save'],
          selected: 1,
          icons: [Icons.edit_outlined, Icons.check_rounded],
        ),
      ),
      TutorialStep(
        'Settings and logging out',
        'Profile → App Settings lets you switch between Light Mode and Dark '
            'Mode and change your password. Tap Logout at the bottom of the '
            'Profile tab to sign out.',
        IconsVisual([
          (Icons.settings_outlined, 'App Settings'),
          (Icons.dark_mode_outlined, 'Dark Mode'),
          (Icons.logout_rounded, 'Logout'),
        ]),
      ),
    ],
    tips: [
      'Your saved pets and Pet Matcher answers follow your account, so they '
          'are there when you log in on another phone.',
      'You can retake Pet Matcher any time from the "Find your perfect '
          'match" card on Home.',
    ],
  ),
  TutorialSection(
    id: 'navigation',
    title: 'Navigating the App',
    subtitle: 'Find your way around every section',
    icon: Icons.explore_rounded,
    color: tealColor,
    whereToFind: 'The bar at the bottom of every main screen',
    steps: [
      TutorialStep(
        'Home',
        'Your starting point: the "Find your perfect match" card, Categories '
            '(Dogs and Cats), Featured Pets and All Available Pets.',
        TabsVisual(0),
      ),
      TutorialStep(
        'Pets',
        'Every rescue in one list, with search and filters.',
        TabsVisual(1),
      ),
      TutorialStep(
        'AR View',
        'See a pet in your own room with the camera, or turn its 3D model in '
            '3D Studio.',
        TabsVisual(2),
      ),
      TutorialStep(
        'Feed',
        'The JALRG community: announcements, pet care tips and Success '
            'Stories from adopters.',
        TabsVisual(3),
      ),
      TutorialStep(
        'Profile',
        'Your applications, appointments, adoption journey, saved pets, '
            'settings, Help & Support, and this guide.',
        TabsVisual(4),
      ),
      TutorialStep(
        'Going back',
        'Tap the ← arrow at the top left, or use your phone\'s back button. '
            'Tap the My Future Pet logo at the top of a tab to jump to Home.',
        IconsVisual([
          (Icons.arrow_back_ios_new_rounded, 'Back'),
          (Icons.home_rounded, 'Logo → Home'),
        ]),
      ),
      TutorialStep(
        'Refreshing',
        'Pull a list down with your finger and let go to load the newest '
            'pets, posts and updates.',
        GestureVisual(Icons.swipe_down_rounded, 'Pull down to refresh'),
      ),
    ],
    iconGuide: [
      (Icons.favorite_border_rounded, 'Save a pet to Saved Pets'),
      (
        Icons.notifications_none_rounded,
        'Notifications (a red number means unread)',
      ),
      (Icons.search_rounded, 'Search'),
      (Icons.share_outlined, 'Share a pet or post'),
      (Icons.view_in_ar_rounded, 'View in AR / 3D'),
      (Icons.camera_alt_outlined, 'Capture an AR photo'),
      (Icons.help_outline_rounded, 'Help for the current screen'),
    ],
  ),
  TutorialSection(
    id: 'browse',
    title: 'Browsing & Searching',
    subtitle: 'Find rescued dogs and cats with search and filters',
    icon: Icons.search_rounded,
    color: Color(0xFF2F6FB5),
    whereToFind: 'The Pets tab (or "See all" on Home)',
    steps: [
      TutorialStep(
        'Open the Pets tab',
        'Tap Pets in the bottom bar. You will see every rescue with its photo, '
            'breed, age and status.',
        TabsVisual(1),
      ),
      TutorialStep(
        'Search by name or breed',
        'Tap the search box and type a pet\'s name (like "Bantay") or a breed '
            '(like "Aspin"). The list updates as you type.',
        FieldsVisual([(Icons.search_rounded, 'Search by name or breed')]),
      ),
      TutorialStep(
        'Dogs or cats',
        'Tap All, Dogs or Cats to show only that kind of pet.',
        ChipsVisual(['All', 'Dogs', 'Cats'], selected: 1),
      ),
      TutorialStep(
        'Use the filters',
        'Tap a filter and pick an option:\n'
            '• Breed – e.g. Aspin (Native Dog)\n'
            '• Age – Under 1 year, 1 - 3 years, or 4+ years\n'
            '• Gender – Male or Female\n'
            '• Status – Available or Pending',
        ChipsVisual(['Breed', 'Age', 'Gender', 'Status'], selected: 1),
      ),
      TutorialStep(
        'Clear the filters',
        'Tap Clear Filters to see every pet again. If nothing matches, the '
            'app shows "No pets found" so you can loosen your search.',
        ChipsVisual(['Clear Filters'], icons: [Icons.close_rounded]),
      ),
      TutorialStep(
        'Save your favorites',
        'Tap the heart on a pet card to save it. Find all of them in '
            'Profile → Saved Pets. Tap the heart again to remove it.',
        IconsVisual([
          (Icons.favorite_border_rounded, 'Tap to save'),
          (Icons.favorite_rounded, 'Saved'),
        ]),
      ),
      TutorialStep(
        'See how well a pet matches you',
        'After you take Pet Matcher, every available pet card shows a "% '
            'Match" badge. Green means a great fit for your lifestyle.',
        ButtonVisual(
          '92% Match',
          icon: Icons.favorite_rounded,
          color: tealColor,
        ),
      ),
    ],
    tips: [
      'Available pets can be adopted now. Pending means someone has already '
          'applied, but you can still view the pet.',
      'Each pet\'s coat color, size and weight are shown on its profile.',
    ],
  ),
  TutorialSection(
    id: 'pet-profile',
    title: 'Pet Profiles',
    subtitle: 'Photos, personality, health and vaccination details',
    icon: Icons.info_outline_rounded,
    color: Color(0xFF7C4DBA),
    whereToFind: 'Tap any pet card on Home or the Pets tab',
    steps: [
      TutorialStep(
        'Open a pet',
        'Tap a pet\'s card on Home or the Pets tab to open its full profile.',
        GestureVisual(Icons.touch_app_rounded, 'Tap a pet card'),
      ),
      TutorialStep(
        'Check the status',
        'The banner tells you whether the pet is "Available for Free '
            'Adoption", has an "Adoption Pending", or is "Already Adopted".',
        ChipsVisual(['Available', 'Pending', 'Adopted'], selected: 0),
      ),
      TutorialStep(
        'Quick facts',
        'See the pet\'s Age, Gender, Size, Weight and Coat Color at a glance.',
        ChipsVisual(['Age', 'Gender', 'Size', 'Weight', 'Coat Color']),
      ),
      TutorialStep(
        'Personality and story',
        'Personality lists traits the shelter noticed (for example "Calm" or '
            '"Playful"). The About section tells where the pet was rescued and '
            'what it is like.',
        IconsVisual([
          (Icons.emoji_emotions_outlined, 'Personality'),
          (Icons.menu_book_outlined, 'About'),
        ]),
      ),
      TutorialStep(
        'Health & Medical Status',
        'Check Vaccination, Deworming, Rabies Protection and Health Condition. '
            '"Not recorded" means the shelter has not added that detail yet.',
        IconsVisual([
          (Icons.vaccines_outlined, 'Vaccination'),
          (Icons.medication_outlined, 'Deworming'),
          (Icons.health_and_safety_outlined, 'Rabies'),
          (Icons.monitor_heart_outlined, 'Health'),
        ]),
      ),
      TutorialStep(
        'What you can do next',
        'Tap Adopt Me to apply, View in AR to see the pet in your room, '
            'Schedule Visit to meet it at the shelter, the heart to save it, '
            'or Share to send it to a friend.',
        ChipsVisual(
          ['Adopt Me', 'View in AR', 'Schedule Visit'],
          selected: 0,
          icons: [
            Icons.favorite_rounded,
            Icons.view_in_ar_rounded,
            Icons.calendar_month_rounded,
          ],
        ),
      ),
    ],
    tips: [
      'The heart and share buttons sit at the top right of the pet\'s photo.',
    ],
  ),
  TutorialSection(
    id: 'ar',
    title: 'AR Pet Visualization',
    subtitle: 'Place a life-size virtual pet in your room',
    icon: Icons.view_in_ar_rounded,
    color: Color(0xFF008F82),
    whereToFind: 'The AR View tab, or "View in AR" on a pet\'s profile',
    steps: [
      TutorialStep(
        'Open AR View',
        'Tap AR View in the bottom bar and choose a pet from the list, or tap '
            'View in AR on a pet\'s profile.',
        TabsVisual(2),
      ),
      TutorialStep(
        'Allow the camera',
        'The first time, your phone asks to use the camera. Tap Allow, because '
            'AR needs the camera to see your room.',
        ButtonVisual(
          'Allow',
          icon: Icons.camera_alt_outlined,
          color: tealColor,
        ),
      ),
      TutorialStep(
        'Choose Camera AR',
        'At the top of AR View, make sure Camera AR is selected.',
        ChipsVisual(
          ['Camera AR', '3D Studio'],
          selected: 0,
          icons: [Icons.camera_alt_outlined, Icons.view_in_ar_rounded],
        ),
      ),
      TutorialStep(
        'Scan the floor',
        'Point your phone at the floor of a well-lit room and move it slowly '
            'from side to side. Keep going until the app finds the floor.',
        GestureVisual(
          Icons.screen_rotation_alt_rounded,
          'Move the phone slowly',
        ),
      ),
      TutorialStep(
        'Place your pet',
        'Tap the floor, below the horizon line, to place the pet at its real '
            'size.',
        GestureVisual(Icons.touch_app_rounded, 'Tap the floor'),
      ),
      TutorialStep(
        'Move and resize',
        'Drag the pet with your finger to move it. Use Enlarge Pet and Shrink '
            'Pet to change its size, and Reset AR Position to place it again.',
        IconsVisual([
          (Icons.open_with_rounded, 'Drag to Move'),
          (Icons.zoom_in_rounded, 'Enlarge Pet'),
          (Icons.zoom_out_rounded, 'Shrink Pet'),
          (Icons.refresh_rounded, 'Reset'),
        ]),
      ),
      TutorialStep(
        'Make it react',
        'Tap Sit, Wag Tail or Speak to see the pet respond in your room.',
        ChipsVisual(['Sit', 'Wag Tail', 'Speak'], selected: 1),
      ),
      TutorialStep(
        'Take a photo',
        'Tap the camera button to capture the view, then save or share it.',
        IconsVisual([(Icons.camera_alt_rounded, 'Capture this view')]),
      ),
    ],
    tips: [
      'Bright light and a floor with some pattern (tiles, wood, a rug) help '
          'the phone find the floor faster.',
      'If you see "Preview only: no ARCore on this phone", your phone does '
          'not support real AR. Use 3D Studio instead, as shown in the next '
          'guide.',
      'Tap the ? button in AR View at any time for a quick reminder.',
    ],
  ),
  TutorialSection(
    id: '3d',
    title: 'Interactive 3D Preview',
    subtitle: 'Rotate, zoom and animate the 3D pet (works on any phone)',
    icon: Icons.threed_rotation_rounded,
    color: Color(0xFFE08A1E),
    whereToFind: 'AR View → 3D Studio',
    steps: [
      TutorialStep(
        'Open 3D Studio',
        'In AR View, tap 3D Studio at the top. It does not need the camera or '
            'ARCore, so it works on every phone.',
        ChipsVisual(
          ['Camera AR', '3D Studio'],
          selected: 1,
          icons: [Icons.camera_alt_outlined, Icons.view_in_ar_rounded],
        ),
      ),
      TutorialStep(
        'Rotate',
        'Drag one finger left or right across the pet to turn it all the way '
            'around (360°).',
        GestureVisual(Icons.swipe_rounded, 'Drag to turn 360°'),
      ),
      TutorialStep(
        'Zoom',
        'Pinch two fingers apart to zoom in on details like fur and face, and '
            'pinch together to zoom out.',
        GestureVisual(Icons.pinch_rounded, 'Pinch to zoom'),
      ),
      TutorialStep(
        'Play animations',
        'Tap Sit to make the pet sit (tap Stand to get up again), Wag Tail to '
            'see it wag, and Speak to hear it bark or meow.',
        ChipsVisual(['Sit', 'Wag Tail', 'Speak'], selected: 0),
      ),
      TutorialStep(
        'Start over',
        'Tap the reset button on the side to bring the model back to its '
            'starting view.',
        IconsVisual([(Icons.refresh_rounded, 'Reset view')]),
      ),
    ],
    tips: [
      'If a pet shows "No 3D model is available for this pet yet", tap '
          'Choose another pet. The shelter adds models over time.',
      'The model may take a few seconds to download the first time. The '
          'pet\'s photo shows while it loads.',
    ],
  ),
  TutorialSection(
    id: 'adoption',
    title: 'Adoption Requests',
    subtitle: 'Apply to adopt and follow your application',
    icon: Icons.assignment_turned_in_rounded,
    color: Color(0xFFC2185B),
    whereToFind:
        'Adopt Me on a pet\'s profile; track it in Profile → My Applications',
    steps: [
      TutorialStep(
        'Choose your pet',
        'Open the profile of the pet you want and read its details and health '
            'information first.',
        GestureVisual(Icons.touch_app_rounded, 'Open the pet\'s profile'),
      ),
      TutorialStep(
        'Tap Adopt Me',
        'This opens the Adoption Application. It has 6 short steps, and the '
            'top shows which step you are on.',
        ButtonVisual('Adopt Me', icon: Icons.favorite_rounded),
      ),
      TutorialStep(
        'Fill in each step',
        'Answer each part, then tap Next Step (or Back to fix something):',
        StagesVisual([
          'Personal Information',
          'Household Information',
          'Pet Experience',
          'Lifestyle & Preferences',
          'Adoption Preferences',
          'Review & Submit',
        ]),
      ),
      TutorialStep(
        'Review and submit',
        'Check your answers, tick the agreement that you will give the pet '
            'proper care, then tap Submit Application.',
        ButtonVisual('Submit Application', icon: Icons.send_rounded),
      ),
      TutorialStep(
        'Follow your progress',
        'Go to Profile → My Applications. A progress road shows where your '
            'application is, and moves forward as the shelter reviews it.',
        StagesVisual([
          'Submitted',
          'Reviewing',
          'Interview',
          'Meet & Greet',
          'Home',
        ]),
      ),
      TutorialStep(
        'Book a visit',
        'Tap Schedule Visit on the pet\'s profile (or Book Meet & Greet when '
            'your journey reaches that stage). Pick Shelter Visit or Meet and '
            'Greet, then a date and time, and tap Request Appointment. See '
            'your bookings in Profile → My Appointments.',
        ChipsVisual(['Shelter Visit', 'Meet and Greet'], selected: 1),
      ),
    ],
    tips: [
      'You must be at least 18 years old to adopt.',
      'Enter a mobile number like 09123456789 so the shelter can reach you.',
      'Adoption at JALRG is free. After your pet comes home, share their '
          'Success Story in the Feed.',
    ],
  ),
  TutorialSection(
    id: 'notifications',
    title: 'Notifications',
    subtitle: 'Stay updated on applications, visits and news',
    icon: Icons.notifications_rounded,
    color: Color(0xFFE53935),
    whereToFind: 'The bell at the top right of Home, Pets, Feed and Profile',
    steps: [
      TutorialStep(
        'Open your notifications',
        'Tap the bell at the top right. A red number on it shows how many '
            'notifications you have not read yet.',
        IconsVisual([(Icons.notifications_none_rounded, 'Bell (3 unread)')]),
      ),
      TutorialStep(
        'Filter the list',
        'Tap All to see everything, Announcements for news from JALRG, or '
            'Updates for things about you.',
        ChipsVisual(['All', 'Announcements', 'Updates'], selected: 2),
      ),
      TutorialStep(
        'Understand the updates',
        'Updates tell you when your adoption application moves forward (for '
            'example Reviewing or Approved) and when a visit is confirmed. '
            'Announcements are shelter news and events.',
        IconsVisual([
          (Icons.assignment_turned_in_outlined, 'Application'),
          (Icons.event_available_outlined, 'Appointment'),
          (Icons.campaign_outlined, 'Announcement'),
        ]),
      ),
      TutorialStep(
        'Mark as read',
        'Tap a notification to read it, or tap Mark all read to clear the red '
            'number.',
        ChipsVisual(['Mark all read'], icons: [Icons.done_all_rounded]),
      ),
      TutorialStep(
        'Phone alerts',
        'When your phone asks, allow notifications from My Future Pet. Then '
            'big news, like your application being approved, also appears in '
            'your phone\'s status bar while the app is open.',
        ButtonVisual(
          'Allow',
          icon: Icons.notifications_active_outlined,
          color: tealColor,
        ),
      ),
    ],
    tips: [
      'When your application reaches a new stage, the progress road on your '
          'Profile celebrates with you.',
    ],
  ),
];
