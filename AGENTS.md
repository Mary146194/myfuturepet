# My Future Pet — Mobile App Agent Protocol & Architecture (myfuturepet/AGENTS.md)
# Standard: Autonomous High-Rigor Mobile Engineering & Verification

---

## 1. Project & Domain Grounding
- **Project:** My Future Pet — Mobile Pet Adoption with AR Pet Visualization.
- **Capstone Context:** BSIT Capstone, Cristal e-College (Panglao, Bohol, Philippines, 2026).
- **Client & Beneficiary:** **Jagna Animal Lover and Rescue Group (JALRG)** in Jagna, Bohol.
- **Tech Stack:** Flutter 3.x, Dart null-safe, `supabase_flutter`.
- **Backend:** Supabase Cloud (`https://szdjfucozmsxqjvctptv.supabase.co`).

---

## 2. Core Database Schema & Columns (Supabase `szdjfucozmsxqjvctptv`)
- `pets`: `id` (UUID), `shelter_id` (UUID), `name`, `type` ('dog', 'cat'), `breed`, `age`, `birthdate`, `gender` ('Male', 'Female'), `size`, `description`, `status` ('available', 'pending', 'adopted'), `photo_urls` (text[]), `image_url` (text), `model_url` (text, .glb path), `vaccination_status`, `health_condition`, `deworming`, `rabies`.
- `adoption_applications`: `id`, `pet_id`, `applicant_id`, `status` ('pending', 'approved', 'rejected'), `applicant_name`, `applicant_phone`, `applicant_email`, `applicant_address`, `housing_type`, `has_yard`, `previous_experience`, `reason_for_adoption`, `questionnaire_answers` (jsonb), `submitted_at`.
- `appointments`: `id`, `shelter_id`, `user_id`, `pet_id`, `scheduled_at` (timestamptz, Philippine Time UTC+8), `appointment_type` ('shelter_visit', 'meet_and_greet'), `status` ('pending', 'confirmed', 'completed', 'cancelled'), `notes`.
- `community_posts`: `id`, `user_id`, `title`, `content`, `image_url`, `likes_count`, `created_at`.
- `post_likes`: `id`, `post_id`, `user_id`, `created_at`.
- `profiles`: `id` (UUID ref auth.users), `display_name`, `email`, `role` ('adopter', 'shelter_staff', 'admin'), `shelter_id`, `phone`, `avatar_url`.

---

## 3. Milestones & Current Progress
- **Step 1 (Complete):** Live pet cards on Home screen (`home_screen.dart`, `pet_service.dart`).
- **Step 2 (Complete):** Pet details (`pet_details_screen.dart`) and Adoption form (`adoption_process_screen.dart`, `adoption_service.dart`).
- **Step 3 (Complete):** Shelter visit bookings (`visit_appointment_screen.dart`, `my_appointments_screen.dart`, `appointment_service.dart`).
- **Step 4 (Complete):** Mobile Community Feed (`feed_screen.dart`, `community_service.dart`).
- **Step 5 (Complete):** Native AR Floor Plane Tracking + 3D Interactive Studio turntable. **74 tests passing.**
- **Step 6 (Active Next):** Add one-tap Facebook Messenger and Phone dialer buttons on `pet_details_screen.dart` and build Android APK.

---

## 4. Invariants & Rules of Engagement
1. **Never break working Auth**: Preserve `auth_service.dart`, `login_screen.dart`, and `register_screen.dart`.
2. **Never drop/wipe Supabase tables**: Database records and schema are live and verified.
3. **Always verify with `flutter analyze`**: Must pass with **0 errors and 0 warnings**.
4. **Maintain automated test suite**: Run `flutter test` and keep existing 74+ tests passing.
5. **Always log session progress**: Append dated notes to `../AI_SESSION_HANDOFF.md` upon completing any milestone.
6. **Multi-Agent Workspace Isolation**: Never allow concurrent edits by multiple AI tools to the same file.
7. **AR Standards**: Preserve `<model-viewer>` script in `web/index.html` and never strip toolbars/buttons when switching view modes.
8. **Client-First Workflow**: Prioritize Jagna Shelter's real-world Facebook Messenger and phone channels for adopter communications.
