# My Future Pet — Mobile App (Flutter) Claude Guidelines

## 1. Project Context
- **Project:** My Future Pet — Mobile Pet Adoption with AR Pet Visualization (BSIT Capstone, Cristal e-College, 2026).
- **Client / Beneficiary:** **Jagna Animal Lover and Rescue Group (JALRG)** in Jagna, Bohol.
- **Tech Stack:** Flutter 3.x (Dart), `supabase_flutter` for Auth, Database, Realtime, and Storage CDN.
- **Backend Supabase URL:** `https://szdjfucozmsxqjvctptv.supabase.co`

---

## 2. Current App Progress & Architecture
- **Auth Flow:** Complete and working (`splash_screen.dart`, `onboarding_screen.dart`, `login_screen.dart`, `register_screen.dart`).
- **Home Screen:** Located in `lib/screens/home_screen.dart` (authenticated session connected, displays user name, currently has UI stubs for pets).
- **Compilation Status:** `flutter analyze` passes with **0 errors**.
- **Related Spec Documents:** Check parent directory for [SYSTEM_ARCHITECTURE_AND_ERD_SPECIFICATION.md](file:///c:/Users/Acer%20User/Videos/MyFuturePetV1/SYSTEM_ARCHITECTURE_AND_ERD_SPECIFICATION.md) and [AI_SESSION_HANDOFF.md](file:///c:/Users/Acer%20User/Videos/MyFuturePetV1/AI_SESSION_HANDOFF.md).

---

## 3. What Needs to Be Done (Roadmap)
1. **Connect Home Screen to Supabase `pets` Table**:
   - Query: `supabase.from('pets').select('*').eq('status', 'available')`
   - Render pet cards with photos, breed, age, gender, and rescue badges.
2. **Implement Pet Detail & Adoption Application**:
   - `PetDetailScreen`: Pet bio, health/vaccination status, "Adopt Me" button, "View in AR" button.
   - `AdoptionFormScreen`: Form collecting housing type, yard availability, and pet experience. Inserts directly into `public.adoption_applications`.
3. **Implement Shelter Visit Booking**:
   - Date & time slot picker inserting into `public.appointments` for Jagna Animal Lover and Rescue Group.
4. **Implement Community Feed**:
   - Screen reading and writing to `public.community_posts` with likes (`public.post_likes`).
5. **AR Pet Visualization**:
   - Interactive 3D model viewing (.glb files via `model_url` from Supabase storage).

---

## 4. DOs and DON'Ts
- **DO** run `flutter analyze` after modifying code. Keep errors at 0.
- **DO** use null-safe Dart and handle asynchronous Supabase calls with proper error handling (`try/catch` with user-friendly SnackBars).
- **DON'T** modify or break the existing Authentication flow in `lib/screens/login_screen.dart`, `register_screen.dart`, or `lib/services/auth_service.dart`.
- **DON'T** run destructive SQL commands or wipe database tables.
- **DON'T** hardcode dummy pet data when live pets already exist in the Supabase database.
- **DON'T** replace Supabase with Firebase.

---

## 5. Verification Commands
```bash
flutter pub get
flutter analyze
flutter test
flutter run
```
