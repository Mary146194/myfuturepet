import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;

  static const Color primaryColor =
      Color(0xFFA94327);

  static const Color backgroundColor =
      Color(0xFFF2F6F8);

  static const Color textColor =
      Color(0xFF263B43);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // =========================
  // LOGIN
  // =========================

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showMessage(
        'Please enter your email and password.',
        Colors.red,
      );
      return;
    }

    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _authService.login(
        email: email,
        password: password,
      );

      if (!mounted) return;

      if (response.user != null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const HomeScreen(),
          ),
          (route) => false,
        );
      }
    } on AuthException catch (e) {
      if (!mounted) return;

      _showMessage(
        e.message,
        Colors.red,
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Login failed. Please check your email and password.',
        Colors.red,
      );

      debugPrint('LOGIN ERROR: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // =========================
  // FORGOT PASSWORD
  // =========================

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showMessage(
        'Please enter your email address first.',
        Colors.orange,
      );
      return;
    }

    try {
      await Supabase.instance.client.auth
          .resetPasswordForEmail(email);

      if (!mounted) return;

      _showMessage(
        'Password reset email sent. Please check your inbox.',
        Colors.green,
      );
    } on AuthException catch (e) {
      if (!mounted) return;

      _showMessage(
        e.message,
        Colors.red,
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Unable to send password reset email.',
        Colors.red,
      );
    }
  }

  // =========================
  // GOOGLE LOGIN
  // =========================

  Future<void> _googleLogin() async {
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo:
            'io.supabase.myfuturepet://login-callback/',
      );
    } on AuthException catch (e) {
      if (!mounted) return;

      _showMessage(
        e.message,
        Colors.red,
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Google login error: $e',
        Colors.red,
      );
    }
  }

  // =========================
  // SNACKBAR
  // =========================

  void _showMessage(
    String message,
    Color color,
  ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // =========================
  // BUILD
  // =========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      // The screen itself will not scroll
      resizeToAvoidBottomInset: false,

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: FittedBox(
                fit: BoxFit.contain,

                child: SizedBox(
                  width: 360,
                  height: 700,

                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),

                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 26,
                        vertical: 24,
                      ),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(22),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                              0.06,
                            ),
                            blurRadius: 20,
                            offset: const Offset(
                              0,
                              8,
                            ),
                          ),
                        ],
                      ),

                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,

                        children: [
                          // =====================
                          // PAW ICON
                          // =====================

                          Container(
                            width: 46,
                            height: 46,

                            decoration: const BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                            ),

                            child: const Icon(
                              Icons.pets,
                              color: Colors.white,
                              size: 25,
                            ),
                          ),

                          const SizedBox(height: 18),

                          // =====================
                          // TITLE
                          // =====================

                          const Text(
                            'Welcome',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),

                          const SizedBox(height: 8),

                          const Text(
                            'Sign in to continue your adoption journey.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF756B68),
                            ),
                          ),

                          const SizedBox(height: 22),

                          // =====================
                          // EMAIL
                          // =====================

                          SizedBox(
                            height: 46,

                            child: TextField(
                              controller: _emailController,

                              keyboardType:
                                  TextInputType.emailAddress,

                              textInputAction:
                                  TextInputAction.next,

                              style: const TextStyle(
                                fontSize: 13,
                              ),

                              decoration:
                                  _inputDecoration(
                                hint: 'Email Address',
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          // =====================
                          // PASSWORD
                          // =====================

                          SizedBox(
                            height: 46,

                            child: TextField(
                              controller:
                                  _passwordController,

                              obscureText:
                                  _obscurePassword,

                              textInputAction:
                                  TextInputAction.done,

                              onSubmitted: (_) {
                                _login();
                              },

                              style: const TextStyle(
                                fontSize: 13,
                              ),

                              decoration:
                                  _inputDecoration(
                                hint: 'Password',

                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons
                                            .visibility_off_outlined
                                        : Icons
                                            .visibility_outlined,
                                    size: 19,
                                    color:
                                        const Color(
                                      0xFF756B68,
                                    ),
                                  ),

                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword =
                                          !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),

                          // =====================
                          // FORGOT PASSWORD
                          // =====================

                          Align(
                            alignment:
                                Alignment.centerRight,

                            child: TextButton(
                              onPressed:
                                  _forgotPassword,

                              style:
                                  TextButton.styleFrom(
                                padding:
                                    const EdgeInsets.only(
                                  top: 3,
                                  bottom: 3,
                                ),

                                minimumSize:
                                    Size.zero,

                                tapTargetSize:
                                    MaterialTapTargetSize
                                        .shrinkWrap,
                              ),

                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: primaryColor,
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // =====================
                          // LOGIN BUTTON
                          // =====================

                          SizedBox(
                            width: double.infinity,
                            height: 42,

                            child: ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : _login,

                              style:
                                  ElevatedButton.styleFrom(
                                backgroundColor:
                                    primaryColor,

                                foregroundColor:
                                    Colors.white,

                                disabledBackgroundColor:
                                    primaryColor,

                                elevation: 0,

                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                    25,
                                  ),
                                ),
                              ),

                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,

                                      child:
                                          CircularProgressIndicator(
                                        color:
                                            Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Login',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight:
                                            FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 22),

                          // =====================
                          // OR CONTINUE WITH
                          // =====================

                          const Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: Color(
                                    0xFFE3D6D1,
                                  ),
                                  thickness: 1,
                                ),
                              ),

                              Padding(
                                padding:
                                    EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),

                                child: Text(
                                  'Or continue with',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Color(
                                      0xFF756B68,
                                    ),
                                  ),
                                ),
                              ),

                              Expanded(
                                child: Divider(
                                  color: Color(
                                    0xFFE3D6D1,
                                  ),
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          // =====================
                          // GOOGLE BUTTON
                          // =====================

                          SizedBox(
                            width: double.infinity,
                            height: 40,

                            child: OutlinedButton(
                              onPressed: _googleLogin,

                              style:
                                  OutlinedButton.styleFrom(
                                foregroundColor:
                                    textColor,

                                side: const BorderSide(
                                  color: Color(
                                    0xFFE2C7BF,
                                  ),
                                  width: 1,
                                ),

                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                    22,
                                  ),
                                ),
                              ),

                              child: const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,

                                children: [
                                  Text(
                                    'G',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight:
                                          FontWeight.bold,
                                      color: Color(
                                        0xFF4285F4,
                                      ),
                                    ),
                                  ),

                                  SizedBox(width: 10),

                                  Text(
                                    'Google',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight:
                                          FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 25),

                          // =====================
                          // REGISTER
                          // =====================

                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,

                            children: [
                              const Text(
                                "Don't have an account? ",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Color(
                                    0xFF756B68,
                                  ),
                                ),
                              ),

                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const RegisterScreen(),
                                    ),
                                  );
                                },

                                child: const Text(
                                  'Register',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight:
                                        FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // =========================
  // INPUT DESIGN
  // =========================

  InputDecoration _inputDecoration({
    required String hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,

      hintStyle: const TextStyle(
        color: Color(0xFF756B68),
        fontSize: 11,
      ),

      suffixIcon: suffixIcon,

      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(8),

        borderSide: const BorderSide(
          color: Color(0xFF9A776D),
          width: 0.8,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(8),

        borderSide: const BorderSide(
          color: primaryColor,
          width: 1.5,
        ),
      ),
    );
  }
}








// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// import '../services/auth_service.dart';
// import 'home_screen.dart';
// import 'register_screen.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   // ------------------------------------------------------------
//   // CONTROLLERS
//   // ------------------------------------------------------------

//   final TextEditingController _emailController =
//       TextEditingController();

//   final TextEditingController _passwordController =
//       TextEditingController();

//   // ------------------------------------------------------------
//   // VARIABLES
//   // ------------------------------------------------------------

//   bool _isLoading = false;
//   bool _obscurePassword = true;

//   // ------------------------------------------------------------
//   // DISPOSE
//   // ------------------------------------------------------------

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();

//     super.dispose();
//   }

//   // ------------------------------------------------------------
//   // LOGIN
//   // ------------------------------------------------------------

//   Future<void> _login() async {
//     // Check if fields are empty
//     if (_emailController.text.trim().isEmpty ||
//         _passwordController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text(
//             'Please enter your email and password.',
//           ),
//           backgroundColor: Colors.red,
//         ),
//       );

//       return;
//     }

//     // Prevent multiple login attempts
//     if (_isLoading) return;

//     try {
//       setState(() {
//         _isLoading = true;
//       });

//       // Call Supabase through AuthService
//       final response = await AuthService().login(
//         email: _emailController.text.trim(),
//         password: _passwordController.text,
//       );

//       if (!mounted) return;

//       // Login successful
//       if (response.user != null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text(
//               'Login successful!',
//             ),
//             backgroundColor: Colors.green,
//           ),
//         );

//         // Go to Home Screen
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) => const HomeScreen(),
//           ),
//         );
//       }
//     }

//     // Supabase authentication error
//     on AuthException catch (e) {
//       if (!mounted) return;

//       print('SUPABASE LOGIN ERROR: ${e.message}');

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             e.message,
//           ),
//           backgroundColor: Colors.red,
//           duration: const Duration(seconds: 4),
//         ),
//       );
//     }

//     // Other errors
//     catch (e) {
//       if (!mounted) return;

//       print('LOGIN ERROR: $e');

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'Login error: $e',
//           ),
//           backgroundColor: Colors.red,
//           duration: const Duration(seconds: 4),
//         ),
//       );
//     }

//     // Stop loading
//     finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   // ------------------------------------------------------------
//   // FORGOT PASSWORD
//   // ------------------------------------------------------------

//   Future<void> _forgotPassword() async {
//     final email = _emailController.text.trim();

//     if (email.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text(
//             'Please enter your email address first.',
//           ),
//           backgroundColor: Colors.orange,
//         ),
//       );

//       return;
//     }

//     try {
//       await Supabase.instance.client.auth.resetPasswordForEmail(
//         email,
//       );

//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text(
//             'Password reset email sent. Please check your inbox.',
//           ),
//           backgroundColor: Colors.green,
//           duration: Duration(seconds: 4),
//         ),
//       );
//     } on AuthException catch (e) {
//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             e.message,
//           ),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } catch (e) {
//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'Error: $e',
//           ),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   // ------------------------------------------------------------
//   // GOOGLE LOGIN
//   // ------------------------------------------------------------

//   Future<void> _googleLogin() async {
//     try {
//       await Supabase.instance.client.auth.signInWithOAuth(
//         OAuthProvider.google,
//         redirectTo:
//             'io.supabase.myfuturepet://login-callback/',
//       );
//     } on AuthException catch (e) {
//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             e.message,
//           ),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } catch (e) {
//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'Google login error: $e',
//           ),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   // ------------------------------------------------------------
//   // BUILD
//   // ------------------------------------------------------------

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5FAFD),

//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(
//               horizontal: 30,
//               vertical: 25,
//             ),

//             child: Container(
//               width: double.infinity,

//               padding: const EdgeInsets.symmetric(
//                 horizontal: 30,
//                 vertical: 35,
//               ),

//               decoration: BoxDecoration(
//                 color: Colors.white,

//                 borderRadius: BorderRadius.circular(30),

//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 15,
//                     offset: const Offset(0, 5),
//                   ),
//                 ],
//               ),

//               child: Column(
//                 crossAxisAlignment:
//                     CrossAxisAlignment.center,

//                 children: [

//                   // ------------------------------------------------
//                   // PAW ICON
//                   // ------------------------------------------------

//                   Container(
//                     width: 100,
//                     height: 100,

//                     decoration: const BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: Color(0xFFC95B3A),
//                     ),

//                     child: const Icon(
//                       Icons.pets,
//                       color: Colors.white,
//                       size: 58,
//                     ),
//                   ),

//                   const SizedBox(height: 35),

//                   // ------------------------------------------------
//                   // WELCOME
//                   // ------------------------------------------------

//                   const Text(
//                     'Welcome',

//                     textAlign: TextAlign.center,

//                     style: TextStyle(
//                       fontSize: 40,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF062C35),
//                     ),
//                   ),

//                   const SizedBox(height: 12),

//                   const Text(
//                     'Sign in to continue your adoption journey.',

//                     textAlign: TextAlign.center,

//                     style: TextStyle(
//                       fontSize: 17,
//                       height: 1.5,
//                       color: Color(0xFF756B68),
//                     ),
//                   ),

//                   const SizedBox(height: 35),

//                   // ------------------------------------------------
//                   // EMAIL
//                   // ------------------------------------------------

//                   TextField(
//                     controller: _emailController,

//                     keyboardType:
//                         TextInputType.emailAddress,

//                     textInputAction:
//                         TextInputAction.next,

//                     decoration: InputDecoration(
//                       hintText: 'Email Address',

//                       hintStyle: const TextStyle(
//                         color: Color(0xFF756B68),
//                       ),

//                       contentPadding:
//                           const EdgeInsets.symmetric(
//                         horizontal: 20,
//                         vertical: 20,
//                       ),

//                       enabledBorder:
//                           OutlineInputBorder(
//                         borderRadius:
//                             BorderRadius.circular(12),

//                         borderSide:
//                             const BorderSide(
//                           color: Color(0xFF9A776D),
//                           width: 1,
//                         ),
//                       ),

//                       focusedBorder:
//                           OutlineInputBorder(
//                         borderRadius:
//                             BorderRadius.circular(12),

//                         borderSide:
//                             const BorderSide(
//                           color: Color(0xFFB44728),
//                           width: 2,
//                         ),
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 22),

//                   // ------------------------------------------------
//                   // PASSWORD
//                   // ------------------------------------------------

//                   TextField(
//                     controller:
//                         _passwordController,

//                     obscureText:
//                         _obscurePassword,

//                     textInputAction:
//                         TextInputAction.done,

//                     onSubmitted: (_) {
//                       _login();
//                     },

//                     decoration: InputDecoration(
//                       hintText: 'Password',

//                       hintStyle: const TextStyle(
//                         color: Color(0xFF756B68),
//                       ),

//                       contentPadding:
//                           const EdgeInsets.symmetric(
//                         horizontal: 20,
//                         vertical: 20,
//                       ),

//                       suffixIcon: IconButton(
//                         icon: Icon(
//                           _obscurePassword
//                               ? Icons.visibility_off_outlined
//                               : Icons.visibility_outlined,

//                           color:
//                               const Color(0xFF756B68),
//                         ),

//                         onPressed: () {
//                           setState(() {
//                             _obscurePassword =
//                                 !_obscurePassword;
//                           });
//                         },
//                       ),

//                       enabledBorder:
//                           OutlineInputBorder(
//                         borderRadius:
//                             BorderRadius.circular(12),

//                         borderSide:
//                             const BorderSide(
//                           color: Color(0xFF9A776D),
//                           width: 1,
//                         ),
//                       ),

//                       focusedBorder:
//                           OutlineInputBorder(
//                         borderRadius:
//                             BorderRadius.circular(12),

//                         borderSide:
//                             const BorderSide(
//                           color: Color(0xFFB44728),
//                           width: 2,
//                         ),
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 12),

//                   // ------------------------------------------------
//                   // FORGOT PASSWORD
//                   // ------------------------------------------------

//                   Align(
//                     alignment:
//                         Alignment.centerRight,

//                     child: TextButton(
//                       onPressed:
//                           _forgotPassword,

//                       child: const Text(
//                         'Forgot Password?',

//                         style: TextStyle(
//                           fontSize: 15,
//                           fontWeight:
//                               FontWeight.w600,
//                           color:
//                               Color(0xFFB44728),
//                         ),
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 10),

//                   // ------------------------------------------------
//                   // LOGIN BUTTON
//                   // ------------------------------------------------

//                   SizedBox(
//                     width: double.infinity,
//                     height: 58,

//                     child: ElevatedButton(
//                       onPressed:
//                           _isLoading
//                               ? null
//                               : _login,

//                       style:
//                           ElevatedButton.styleFrom(
//                         backgroundColor:
//                             const Color(0xFFB44728),

//                         disabledBackgroundColor:
//                             const Color(0xFFCF8B78),

//                         foregroundColor:
//                             Colors.white,

//                         elevation: 2,

//                         shape:
//                             RoundedRectangleBorder(
//                           borderRadius:
//                               BorderRadius.circular(30),
//                         ),
//                       ),

//                       child: _isLoading
//                           ? const SizedBox(
//                               width: 25,
//                               height: 25,

//                               child:
//                                   CircularProgressIndicator(
//                                 strokeWidth: 3,
//                                 color: Colors.white,
//                               ),
//                             )
//                           : Row(
//                               mainAxisAlignment:
//                                   MainAxisAlignment.center,

//                               children: const [
//                                 Text(
//                                   'Login',

//                                   style:
//                                       TextStyle(
//                                     fontSize: 17,
//                                     fontWeight:
//                                         FontWeight.w600,
//                                   ),
//                                 ),

//                                 SizedBox(width: 12),

//                                 Icon(
//                                   Icons.arrow_forward,
//                                   size: 25,
//                                 ),
//                               ],
//                             ),
//                     ),
//                   ),

//                   const SizedBox(height: 40),

//                   // ------------------------------------------------
//                   // OR CONTINUE WITH
//                   // ------------------------------------------------

//                   Row(
//                     children: [
//                       Expanded(
//                         child: Container(
//                           height: 1,
//                           color:
//                               const Color(0xFFE4C8C0),
//                         ),
//                       ),

//                       const Padding(
//                         padding:
//                             EdgeInsets.symmetric(
//                           horizontal: 15,
//                         ),

//                         child: Text(
//                           'Or continue with',

//                           style: TextStyle(
//                             fontSize: 16,
//                             color:
//                                 Color(0xFF756B68),
//                           ),
//                         ),
//                       ),

//                       Expanded(
//                         child: Container(
//                           height: 1,
//                           color:
//                               const Color(0xFFE4C8C0),
//                         ),
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 25),

//                   // ------------------------------------------------
//                   // GOOGLE BUTTON
//                   // ------------------------------------------------

//                   SizedBox(
//                     width: double.infinity,
//                     height: 55,

//                     child: OutlinedButton(
//                       onPressed: _googleLogin,

//                       style:
//                           OutlinedButton.styleFrom(
//                         foregroundColor:
//                             const Color(0xFF222222),

//                         side:
//                             const BorderSide(
//                           color: Color(0xFFE2C7BF),
//                           width: 1.5,
//                         ),

//                         shape:
//                             RoundedRectangleBorder(
//                           borderRadius:
//                               BorderRadius.circular(30),
//                         ),
//                       ),

//                       child: Row(
//                         mainAxisAlignment:
//                             MainAxisAlignment.center,

//                         children: [
//                           const Text(
//                             'G',

//                             style: TextStyle(
//                               fontSize: 28,
//                               fontWeight:
//                                   FontWeight.bold,
//                               color:
//                                   Color(0xFF4285F4),
//                             ),
//                           ),

//                           const SizedBox(width: 15),

//                           const Text(
//                             'Google',

//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight:
//                                   FontWeight.w500,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 40),

//                   // ------------------------------------------------
//                   // REGISTER
//                   // ------------------------------------------------

//                   Row(
//                     mainAxisAlignment:
//                         MainAxisAlignment.center,

//                     children: [
//                       const Text(
//                         "Don't have an account? ",

//                         style: TextStyle(
//                           fontSize: 15,
//                           color:
//                               Color(0xFF756B68),
//                         ),
//                       ),

//                       GestureDetector(
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) =>
//                                   const RegisterScreen(),
//                             ),
//                           );
//                         },

//                         child: const Text(
//                           'Register',

//                           style: TextStyle(
//                             fontSize: 15,
//                             fontWeight:
//                                 FontWeight.bold,
//                             color:
//                                 Color(0xFFB44728),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }











// import 'package:flutter/material.dart';

// import '../services/auth_service.dart';
// import 'home_screen.dart';
// import 'register_screen.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() =>
//       _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();

//   final _authService = AuthService();

//   bool _isLoading = false;
//   bool _obscurePassword = true;

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();

//     super.dispose();
//   }

//   Future<void> _login() async {
//     final email = _emailController.text.trim();
//     final password = _passwordController.text;

//     if (email.isEmpty || password.isEmpty) {
//       _showMessage(
//         'Please enter your email and password.',
//       );
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final response = await _authService.login(
//         email: email,
//         password: password,
//       );

//       if (response.user != null) {
//         if (!mounted) return;

//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (_) => const HomeScreen(),
//           ),
//         );
//       }
//     } catch (e) {
//       _showMessage(
//         'Login failed. Please check your email and password.',
//       );
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   Future<void> _forgotPassword() async {
//     final email = _emailController.text.trim();

//     if (email.isEmpty) {
//       _showMessage(
//         'Enter your email address first.',
//       );
//       return;
//     }

//     try {
//       await _authService.resetPassword(email);

//       _showMessage(
//         'Password reset email sent.',
//       );
//     } catch (e) {
//       _showMessage(
//         'Unable to send reset email.',
//       );
//     }
//   }

//   void _showMessage(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5FAFD),

//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(
//               horizontal: 28,
//               vertical: 30,
//             ),

//             child: Container(
//               padding: const EdgeInsets.fromLTRB(
//                 32,
//                 32,
//                 32,
//                 28,
//               ),

//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(28),

//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 25,
//                     offset: const Offset(0, 10),
//                   ),
//                 ],
//               ),

//               child: Column(
//                 children: [
//                   Container(
//                     width: 50,
//                     height: 50,

//                     decoration: BoxDecoration(
//                       color: const Color(0xFFC75A3D),
//                       shape: BoxShape.circle,
//                     ),

//                     child: const Icon(
//                       Icons.pets,
//                       color: Colors.white,
//                       size: 28,
//                     ),
//                   ),

//                   const SizedBox(height: 20),

//                   const Text(
//                     'Welcome',
//                     style: TextStyle(
//                       fontSize: 32,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF062B35),
//                     ),
//                   ),

//                   const SizedBox(height: 8),

//                   const Text(
//                     'Sign in to continue your adoption journey.',
//                     textAlign: TextAlign.center,

//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Color(0xFF6E5D57),
//                     ),
//                   ),

//                   const SizedBox(height: 30),

//                   TextField(
//                     controller: _emailController,

//                     keyboardType:
//                         TextInputType.emailAddress,

//                     decoration: const InputDecoration(
//                       hintText: 'Email Address',
//                     ),
//                   ),

//                   const SizedBox(height: 20),

//                   TextField(
//                     controller: _passwordController,

//                     obscureText: _obscurePassword,

//                     decoration: InputDecoration(
//                       hintText: 'Password',

//                       suffixIcon: IconButton(
//                         onPressed: () {
//                           setState(() {
//                             _obscurePassword =
//                                 !_obscurePassword;
//                           });
//                         },

//                         icon: Icon(
//                           _obscurePassword
//                               ? Icons.visibility_off_outlined
//                               : Icons.visibility_outlined,

//                           color: const Color(0xFF604D48),
//                         ),
//                       ),
//                     ),
//                   ),

//                   Align(
//                     alignment: Alignment.centerRight,

//                     child: TextButton(
//                       onPressed: _forgotPassword,

//                       child: const Text(
//                         'Forgot Password?',
//                         style: TextStyle(
//                           color: Color(0xFFA94327),
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 5),

//                   SizedBox(
//                     width: double.infinity,
//                     height: 54,

//                     child: ElevatedButton(
//                       onPressed:
//                           _isLoading ? null : _login,

//                       style: ElevatedButton.styleFrom(
//                         backgroundColor:
//                             const Color(0xFFA94327),

//                         foregroundColor: Colors.white,

//                         shape: RoundedRectangleBorder(
//                           borderRadius:
//                               BorderRadius.circular(30),
//                         ),
//                       ),

//                       child: _isLoading
//                           ? const SizedBox(
//                               width: 22,
//                               height: 22,

//                               child:
//                                   CircularProgressIndicator(
//                                 strokeWidth: 2,
//                                 color: Colors.white,
//                               ),
//                             )
//                           : const Row(
//                               mainAxisAlignment:
//                                   MainAxisAlignment.center,

//                               children: [
//                                 Text(
//                                   'Login',
//                                   style: TextStyle(
//                                     fontWeight:
//                                         FontWeight.w600,
//                                   ),
//                                 ),

//                                 SizedBox(width: 8),

//                                 Icon(
//                                   Icons.arrow_forward,
//                                   size: 20,
//                                 ),
//                               ],
//                             ),
//                     ),
//                   ),

//                   const SizedBox(height: 30),

//                   Row(
//                     children: [
//                       const Expanded(
//                         child: Divider(),
//                       ),

//                       Padding(
//                         padding:
//                             const EdgeInsets.symmetric(
//                           horizontal: 15,
//                         ),

//                         child: Text(
//                           'Or continue with',
//                           style: TextStyle(
//                             color:
//                                 Colors.grey.shade600,
//                           ),
//                         ),
//                       ),

//                       const Expanded(
//                         child: Divider(),
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 25),

//                   SizedBox(
//                     width: double.infinity,
//                     height: 52,

//                     child: OutlinedButton(
//                       onPressed: () {
//                         _showMessage(
//                           'Google sign-in will be configured next.',
//                         );
//                       },

//                       style: OutlinedButton.styleFrom(
//                         side: const BorderSide(
//                           color: Color(0xFFE1BDB3),
//                         ),

//                         shape: RoundedRectangleBorder(
//                           borderRadius:
//                               BorderRadius.circular(30),
//                         ),
//                       ),

//                       child: const Row(
//                         mainAxisAlignment:
//                             MainAxisAlignment.center,

//                         children: [
//                           Text(
//                             'G',
//                             style: TextStyle(
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.blue,
//                             ),
//                           ),

//                           SizedBox(width: 12),

//                           Text(
//                             'Google',
//                             style: TextStyle(
//                               color: Color(0xFF263238),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 30),

//                   Row(
//                     mainAxisAlignment:
//                         MainAxisAlignment.center,

//                     children: [
//                       const Text(
//                         "Don't have an account? ",
//                         style: TextStyle(
//                           color: Color(0xFF6E5D57),
//                         ),
//                       ),

//                       GestureDetector(
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) =>
//                                   const RegisterScreen(),
//                             ),
//                           );
//                         },

//                         child: const Text(
//                           'Register',
//                           style: TextStyle(
//                             color: Color(0xFFA94327),
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }