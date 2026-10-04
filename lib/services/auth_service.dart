import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase =
      Supabase.instance.client;

  // ==============================
  // CURRENT USER
  // ==============================

  User? get currentUser {
    return _supabase.auth.currentUser;
  }

  // ==============================
  // LOGIN
  // ==============================

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response =
        await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    return response;
  }

  // ==============================
  // REGISTER
  // ==============================

  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response =
        await _supabase.auth.signUp(
      email: email,
      password: password,

      data: {
        'name': name,
      },
    );

    return response;
  }

  // ==============================
  // LOGOUT
  // ==============================

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  // ==============================
  // CHECK SESSION
  // ==============================

  Session? get currentSession {
    return _supabase.auth.currentSession;
  }

  // ==============================
  // AUTH STATE
  // ==============================

  Stream<AuthState> get authStateChanges {
    return _supabase.auth.onAuthStateChange;
  }
}








// import 'package:supabase_flutter/supabase_flutter.dart';

// class AuthService {
//   final SupabaseClient _supabase =
//       Supabase.instance.client;

//   // ============================================================
//   // LOGIN
//   // ============================================================

//   Future<AuthResponse> login({
//     required String email,
//     required String password,
//   }) async {
//     return await _supabase.auth.signInWithPassword(
//       email: email.trim(),
//       password: password,
//     );
//   }

//   // ============================================================
//   // REGISTER
//   // ============================================================

//   Future<AuthResponse> register({
//     required String name,
//     required String email,
//     required String password,
//   }) async {
//     return await _supabase.auth.signUp(
//       email: email.trim(),
//       password: password,
//       data: {
//         'full_name': name.trim(),
//       },
//     );
//   }

//   // ============================================================
//   // LOGOUT
//   // ============================================================

//   Future<void> logout() async {
//     await _supabase.auth.signOut();
//   }

//   // ============================================================
//   // CURRENT USER
//   // ============================================================

//   User? get currentUser {
//     return _supabase.auth.currentUser;
//   }

//   // ============================================================
//   // CURRENT SESSION
//   // ============================================================

//   Session? get currentSession {
//     return _supabase.auth.currentSession;
//   }

//   // ============================================================
//   // CHECK IF LOGGED IN
//   // ============================================================

//   bool get isLoggedIn {
//     return _supabase.auth.currentSession != null;
//   }
// }









// import 'package:supabase_flutter/supabase_flutter.dart';

// class AuthService {
//   final SupabaseClient _supabase =
//       Supabase.instance.client;

//   Future<AuthResponse> login({
//     required String email,
//     required String password,
//   }) async {
//     return await _supabase.auth.signInWithPassword(
//       email: email.trim(),
//       password: password,
//     );
//   }

//   Future<AuthResponse> register({
//     required String email,
//     required String password,
//   }) async {
//     return await _supabase.auth.signUp(
//       email: email.trim(),
//       password: password,
//     );
//   }

//   Future<void> logout() async {
//     await _supabase.auth.signOut();
//   }

//   User? get currentUser {
//     return _supabase.auth.currentUser;
//   }

//   Session? get currentSession {
//     return _supabase.auth.currentSession;
//   }

//   bool get isLoggedIn {
//     return _supabase.auth.currentSession != null;
//   }
// }




// import 'package:supabase_flutter/supabase_flutter.dart';

// class AuthService {
//   final SupabaseClient _supabase = Supabase.instance.client;

//   Future<AuthResponse> login({
//     required String email,
//     required String password,
//   }) async {
//     return await _supabase.auth.signInWithPassword(
//       email: email.trim(),
//       password: password,
//     );
//   }

//   Future<AuthResponse> register({
//     required String name,
//     required String email,
//     required String password,
//   }) async {
//     final response = await _supabase.auth.signUp(
//       email: email.trim(),
//       password: password,
//       data: {
//         'full_name': name.trim(),
//       },
//     );

//     if (response.user != null && response.session != null) {
//       await _supabase.from('profiles').insert({
//         'id': response.user!.id,
//         'full_name': name.trim(),
//         'email': email.trim(),
//       });
//     }

//     return response;
//   }

//   Future<void> resetPassword(String email) async {
//     await _supabase.auth.resetPasswordForEmail(
//       email.trim(),
//     );
//   }

//   Future<void> logout() async {
//     await _supabase.auth.signOut();
//   }

//   User? get currentUser {
//     return _supabase.auth.currentUser;
//   }
// }