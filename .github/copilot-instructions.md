# Copilot & Codex Instructions — My Future Pet (Mobile App)

## Project Context
- **Project Title:** My Future Pet: Mobile Pet Adoption System with AR Pet Visualization
- **Capstone Details:** BSIT Capstone, Cristal e-College (Panglao, Bohol, Philippines, 2026).
- **Client / Beneficiary:** **Jagna Animal Lover and Rescue Group (JALRG)** in Jagna, Bohol.
- **Architecture:** Flutter 3.x with `supabase_flutter`.

---

## Database Schema Reference (Supabase `szdjfucozmsxqjvctptv`)
- `pets`: `id` (UUID), `shelter_id` (UUID), `name`, `type` ('dog', 'cat'), `breed`, `age`, `gender`, `size`, `description`, `status` ('available', 'pending', 'adopted'), `photo_urls` (text[]), `image_url` (text), `model_url` (.glb path), `vaccination_status`, `health_condition`.
- `adoption_applications`: `id`, `pet_id`, `applicant_id`, `status` ('pending', 'approved', 'rejected'), `applicant_name`, `applicant_phone`, `applicant_email`, `applicant_address`, `housing_type`, `has_yard`, `previous_experience`, `reason_for_adoption`, `questionnaire_answers` (jsonb), `submitted_at`.
- `appointments`: `id`, `shelter_id`, `user_id`, `pet_id`, `scheduled_at` (timestamptz, Philippine Time UTC+8), `appointment_type` ('shelter_visit', 'meet_and_greet'), `status` ('pending', 'confirmed', 'completed', 'cancelled'), `notes`.
- `community_posts`: `id`, `user_id`, `title`, `content`, `image_url`, `likes_count`, `created_at`.
- `post_likes`: `id`, `post_id`, `user_id`, `created_at`.

---

## Current Status & Next Steps
- **Step 1 (Complete):** Live available pets feed on Home Screen.
- **Step 2 (Complete):** Pet details and adoption application submission queue.
- **Step 3 (Complete):** Shelter visit bookings and My Appointments screen (52 tests passed).
- **Step 4 (ACTIVE NEXT):** Connect `community_screen.dart` and `community_service.dart` to `public.community_posts` and `public.post_likes`. Implement story creation, image uploads, and real-time like toggles.
- **Step 5 (UPCOMING):** AR 3D Pet Visualization using `.glb` models from `model_url` via `model_viewer_plus` / ARCore.

---

## Invariants (DOs and DON'Ts)
- **DO NOT** modify the working Auth flow (`auth_service.dart`, `login_screen.dart`, `register_screen.dart`).
- **DO NOT** wipe or alter database schemas on Supabase.
- **DO NOT** hardcode mock pet data; fetch directly from Supabase.
- **DO** run `flutter analyze` after every code change and keep **0 errors**.
- **DO** run `flutter test` to ensure tests remain green.
- **DO** handle network/database errors with user-friendly SnackBars.
