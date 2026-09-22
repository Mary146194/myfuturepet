import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController _nameController =
      TextEditingController();

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // ============================================================
  // AUTH SERVICE
  // ============================================================

  final AuthService _authService = AuthService();

  // ============================================================
  // VARIABLES
  // ============================================================

  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptedTerms = false;

  // ============================================================
  // COLORS
  // ============================================================

  static const Color primaryColor = Color(0xFFA94327);
  static const Color darkText = Color(0xFF062B35);
  static const Color secondaryText = Color(0xFF6E5D57);
  static const Color borderColor = Color(0xFFE5BDB2);
  static const Color backgroundColor = Color(0xFFF5FAFD);

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  // ============================================================
  // REGISTER
  // ============================================================

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Check empty fields
    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showMessage(
        'Please complete all fields.',
        isError: true,
      );
      return;
    }

    // Check email
    if (!email.contains('@') || !email.contains('.')) {
      _showMessage(
        'Please enter a valid email address.',
        isError: true,
      );
      return;
    }

    // Check password
    if (password.length < 6) {
      _showMessage(
        'Password must contain at least 6 characters.',
        isError: true,
      );
      return;
    }

    // Check confirm password
    if (password != confirmPassword) {
      _showMessage(
        'Passwords do not match.',
        isError: true,
      );
      return;
    }

    // Check terms
    if (!_acceptedTerms) {
      _showMessage(
        'Please agree to the Terms of Service and Privacy Policy.',
        isError: true,
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final response = await _authService.register(
        name: name,
        email: email,
        password: password,
      );

      if (!mounted) return;

      // If Supabase automatically creates a session
      if (response.session != null) {
        _showMessage(
          'Account created successfully!',
          isError: false,
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const HomeScreen(),
          ),
          (route) => false,
        );
      }

      // If email verification is required
      else {
        _showMessage(
          'Account created! Please check your email to verify your account.',
          isError: false,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginScreen(),
          ),
        );
      }
    } on AuthException catch (e) {
      if (!mounted) return;

      _showMessage(
        e.message,
        isError: true,
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Registration error: $e',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message, {
    required bool isError,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
        backgroundColor:
            isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: backgroundColor,

      // Prevent the entire screen from moving when keyboard appears
      resizeToAvoidBottomInset: false,

      // ========================================================
      // APP BAR / BACK BUTTON
      // ========================================================

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 55,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: primaryColor,
            size: 30,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [

                // ==================================================
                // TOP LOGO
                // ==================================================

                SizedBox(
                  height: size.height * 0.055,
                  child: const Center(
                    child: Icon(
                      Icons.pets,
                      color: primaryColor,
                      size: 30,
                    ),
                  ),
                ),

                // ==================================================
                // MAIN CARD
                // ==================================================

                Expanded(
                  child: Container(
                    width: double.infinity,

                    margin: const EdgeInsets.symmetric(
                      horizontal: 14,
                    ),

                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.07,
                      vertical: size.height * 0.018,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.88),

                      borderRadius:
                          BorderRadius.circular(24),

                      boxShadow: [
                        BoxShadow(
                          color:
                              Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset:
                              const Offset(0, 4),
                        ),
                      ],
                    ),

                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceEvenly,

                      children: [

                        // ==================================================
                        // TITLE
                        // ==================================================

                        Column(
                          children: const [

                            Text(
                              'Create Your Account',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight:
                                    FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),

                            SizedBox(height: 5),

                            Text(
                              'Join our community to find your perfect\ncompanion.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: secondaryText,
                                height: 1.25,
                              ),
                            ),
                          ],
                        ),

                        // ==================================================
                        // FULL NAME
                        // ==================================================

                        _buildField(
                          label: 'Full Name',
                          hint: 'Full Name',
                          icon: Icons.person_outline,
                          controller: _nameController,
                          textInputAction:
                              TextInputAction.next,
                        ),

                        // ==================================================
                        // EMAIL
                        // ==================================================

                        _buildField(
                          label: 'Email',
                          hint: 'email@gmail.com',
                          icon: Icons.email_outlined,
                          controller: _emailController,
                          keyboardType:
                              TextInputType.emailAddress,
                          textInputAction:
                              TextInputAction.next,
                        ),

                        // ==================================================
                        // PASSWORD
                        // ==================================================

                        _buildField(
                          label: 'Password',
                          hint: '••••••••',
                          icon: Icons.lock_outline,
                          controller: _passwordController,
                          obscureText:
                              _obscurePassword,
                          textInputAction:
                              TextInputAction.next,
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword =
                                    !_obscurePassword;
                              });
                            },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color:
                                  const Color(0xFF756B68),
                              size: 21,
                            ),
                          ),
                        ),

                        // ==================================================
                        // CONFIRM PASSWORD
                        // ==================================================

                        _buildField(
                          label: 'Confirm Password',
                          hint: '••••••••',
                          icon: Icons.lock_outline,
                          controller:
                              _confirmPasswordController,
                          obscureText:
                              _obscureConfirmPassword,
                          textInputAction:
                              TextInputAction.done,
                          onSubmitted: (_) {
                            if (!_loading) {
                              _register();
                            }
                          },
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color:
                                  const Color(0xFF756B68),
                              size: 21,
                            ),
                          ),
                        ),

                        // ==================================================
                        // TERMS AND PRIVACY
                        // ==================================================

                        Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [

                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _acceptedTerms,
                                activeColor:
                                    primaryColor,
                                side: const BorderSide(
                                  color:
                                      Color(0xFFD8AFA5),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _acceptedTerms =
                                        value ?? false;
                                  });
                                },
                              ),
                            ),

                            const SizedBox(width: 7),

                            Expanded(
                              child: RichText(
                                text: const TextSpan(
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: secondaryText,
                                    height: 1.35,
                                  ),
                                  children: [

                                    TextSpan(
                                      text:
                                          'I agree to the ',
                                    ),

                                    TextSpan(
                                      text:
                                          'Terms of Service',
                                      style: TextStyle(
                                        color:
                                            Color(0xFF00796B),
                                        fontWeight:
                                            FontWeight.w600,
                                      ),
                                    ),

                                    TextSpan(
                                      text:
                                          ' and ',
                                    ),

                                    TextSpan(
                                      text:
                                          'Privacy Policy',
                                      style: TextStyle(
                                        color:
                                            Color(0xFF00796B),
                                        fontWeight:
                                            FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        // ==================================================
                        // REGISTER BUTTON
                        // ==================================================

                        SizedBox(
                          width: double.infinity,
                          height: 48,

                          child: ElevatedButton(
                            onPressed:
                                _loading
                                    ? null
                                    : _register,

                            style:
                                ElevatedButton.styleFrom(
                              backgroundColor:
                                  primaryColor,

                              disabledBackgroundColor:
                                  const Color(
                                0xFFD39B89,
                              ),

                              foregroundColor:
                                  Colors.white,

                              elevation: 0,

                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  28,
                                ),
                              ),
                            ),

                            child: _loading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color:
                                          Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Register',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight:
                                          FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),

                        // ==================================================
                        // LOGIN
                        // ==================================================

                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const LoginScreen(),
                              ),
                            );
                          },

                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 12,
                                color: secondaryText,
                              ),
                              children: [

                                TextSpan(
                                  text:
                                      'Already have an account? ',
                                ),

                                TextSpan(
                                  text: 'Login',
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ==================================================
                // FOOTER
                // ==================================================

                SizedBox(
                  height: size.height * 0.055,
                  child: const Center(
                    child: Text(
                      'Powered by  ♡ My Future Pet',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF8E817D),
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // INPUT FIELD
  // ============================================================

  Widget _buildField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    Function(String)? onSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(
          label,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: secondaryText,
          ),
        ),

        const SizedBox(height: 5),

        SizedBox(
          height: 42,

          child: TextField(
            controller: controller,

            obscureText: obscureText,

            keyboardType: keyboardType,

            textInputAction: textInputAction,

            onSubmitted: onSubmitted,

            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF403936),
            ),

            decoration: InputDecoration(
              hintText: hint,

              hintStyle: const TextStyle(
                fontSize: 13,
                color: Color(0xFFB1A7A4),
              ),

              prefixIcon: Icon(
                icon,
                size: 18,
                color: const Color(0xFF756B68),
              ),

              suffixIcon: suffixIcon,

              filled: true,

              fillColor: Colors.white,

              contentPadding:
                  const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),

              enabledBorder:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(25),

                borderSide:
                    const BorderSide(
                  color: borderColor,
                  width: 1,
                ),
              ),

              focusedBorder:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(25),

                borderSide:
                    const BorderSide(
                  color: primaryColor,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}









// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// import '../services/auth_service.dart';
// import 'home_screen.dart';
// import 'login_screen.dart';

// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});

//   @override
//   State<RegisterScreen> createState() =>
//       _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> {
//   // ============================================================
//   // CONTROLLERS
//   // ============================================================

//   final TextEditingController _nameController =
//       TextEditingController();

//   final TextEditingController _emailController =
//       TextEditingController();

//   final TextEditingController _passwordController =
//       TextEditingController();

//   final TextEditingController _confirmPasswordController =
//       TextEditingController();

//   // ============================================================
//   // AUTH SERVICE
//   // ============================================================

//   final AuthService _authService = AuthService();

//   // ============================================================
//   // VARIABLES
//   // ============================================================

//   bool _loading = false;
//   bool _obscurePassword = true;
//   bool _obscureConfirmPassword = true;

//   // ============================================================
//   // DISPOSE
//   // ============================================================

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();

//     super.dispose();
//   }

//   // ============================================================
//   // REGISTER
//   // ============================================================

//   Future<void> _register() async {
//     final name = _nameController.text.trim();
//     final email = _emailController.text.trim();
//     final password = _passwordController.text;
//     final confirmPassword =
//         _confirmPasswordController.text;

//     // ----------------------------------------------------------
//     // CHECK EMPTY FIELDS
//     // ----------------------------------------------------------

//     if (name.isEmpty ||
//         email.isEmpty ||
//         password.isEmpty ||
//         confirmPassword.isEmpty) {
//       _showMessage(
//         'Please complete all fields.',
//         isError: true,
//       );
//       return;
//     }

//     // ----------------------------------------------------------
//     // CHECK EMAIL
//     // ----------------------------------------------------------

//     if (!email.contains('@') ||
//         !email.contains('.')) {
//       _showMessage(
//         'Please enter a valid email address.',
//         isError: true,
//       );
//       return;
//     }

//     // ----------------------------------------------------------
//     // CHECK PASSWORD
//     // ----------------------------------------------------------

//     if (password.length < 6) {
//       _showMessage(
//         'Password must contain at least 6 characters.',
//         isError: true,
//       );
//       return;
//     }

//     // ----------------------------------------------------------
//     // CHECK CONFIRM PASSWORD
//     // ----------------------------------------------------------

//     if (password != confirmPassword) {
//       _showMessage(
//         'Passwords do not match.',
//         isError: true,
//       );
//       return;
//     }

//     // ----------------------------------------------------------
//     // START LOADING
//     // ----------------------------------------------------------

//     setState(() {
//       _loading = true;
//     });

//     try {
//       // --------------------------------------------------------
//       // SUPABASE REGISTER
//       // --------------------------------------------------------

//       final response = await _authService.register(
//         name: name,
//         email: email,
//         password: password,
//       );

//       if (!mounted) return;

//       // --------------------------------------------------------
//       // IF SESSION EXISTS
//       // --------------------------------------------------------

//       if (response.session != null) {
//         _showMessage(
//           'Account created successfully!',
//           isError: false,
//         );

//         // Go directly to Home
//         Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(
//             builder: (context) => const HomeScreen(),
//           ),
//           (route) => false,
//         );
//       }

//       // --------------------------------------------------------
//       // IF EMAIL VERIFICATION IS REQUIRED
//       // --------------------------------------------------------

//       else {
//         _showMessage(
//           'Account created! Please check your email to verify your account.',
//           isError: false,
//         );

//         // Go to Login
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) => const LoginScreen(),
//           ),
//         );
//       }
//     }

//     // ----------------------------------------------------------
//     // SUPABASE ERROR
//     // ----------------------------------------------------------

//     on AuthException catch (e) {
//       if (!mounted) return;

//       _showMessage(
//         e.message,
//         isError: true,
//       );
//     }

//     // ----------------------------------------------------------
//     // OTHER ERROR
//     // ----------------------------------------------------------

//     catch (e) {
//       if (!mounted) return;

//       _showMessage(
//         'Registration error: $e',
//         isError: true,
//       );
//     }

//     // ----------------------------------------------------------
//     // STOP LOADING
//     // ----------------------------------------------------------

//     finally {
//       if (mounted) {
//         setState(() {
//           _loading = false;
//         });
//       }
//     }
//   }

//   // ============================================================
//   // MESSAGE
//   // ============================================================

//   void _showMessage(
//     String message, {
//     required bool isError,
//   }) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor:
//             isError ? Colors.red : Colors.green,
//         behavior: SnackBarBehavior.floating,
//         duration: const Duration(seconds: 4),
//       ),
//     );
//   }

//   // ============================================================
//   // BUILD
//   // ============================================================

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5FAFD),

//       // ========================================================
//       // APP BAR
//       // ========================================================

//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,

//         leading: IconButton(
//           icon: const Icon(
//             Icons.arrow_back,
//             color: Color(0xFFA94327),
//           ),

//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//       ),

//       // ========================================================
//       // BODY
//       // ========================================================

//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.fromLTRB(
//             28,
//             10,
//             28,
//             30,
//           ),

//           child: Container(
//             width: double.infinity,

//             padding: const EdgeInsets.all(30),

//             decoration: BoxDecoration(
//               color: Colors.white,

//               borderRadius:
//                   BorderRadius.circular(28),

//               boxShadow: [
//                 BoxShadow(
//                   color:
//                       Colors.black.withOpacity(0.05),
//                   blurRadius: 15,
//                   offset: const Offset(0, 5),
//                 ),
//               ],
//             ),

//             child: Column(
//               children: [
//                 // =================================================
//                 // PET ICON
//                 // =================================================

//                 Container(
//                   width: 80,
//                   height: 80,

//                   decoration:
//                       const BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: Color(0xFFA94327),
//                   ),

//                   child: const Icon(
//                     Icons.pets,
//                     size: 45,
//                     color: Colors.white,
//                   ),
//                 ),

//                 const SizedBox(height: 20),

//                 // =================================================
//                 // TITLE
//                 // =================================================

//                 const Text(
//                   'Create Account',

//                   textAlign: TextAlign.center,

//                   style: TextStyle(
//                     fontSize: 30,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF062B35),
//                   ),
//                 ),

//                 const SizedBox(height: 8),

//                 const Text(
//                   'Start your pet adoption journey.',

//                   textAlign: TextAlign.center,

//                   style: TextStyle(
//                     fontSize: 15,
//                     color: Color(0xFF6E5D57),
//                   ),
//                 ),

//                 const SizedBox(height: 30),

//                 // =================================================
//                 // FULL NAME
//                 // =================================================

//                 TextField(
//                   controller: _nameController,

//                   textInputAction:
//                       TextInputAction.next,

//                   decoration:
//                       _inputDecoration(
//                     hintText: 'Full Name',
//                     icon: Icons.person_outline,
//                   ),
//                 ),

//                 const SizedBox(height: 18),

//                 // =================================================
//                 // EMAIL
//                 // =================================================

//                 TextField(
//                   controller: _emailController,

//                   keyboardType:
//                       TextInputType.emailAddress,

//                   textInputAction:
//                       TextInputAction.next,

//                   decoration:
//                       _inputDecoration(
//                     hintText: 'Email Address',
//                     icon: Icons.email_outlined,
//                   ),
//                 ),

//                 const SizedBox(height: 18),

//                 // =================================================
//                 // PASSWORD
//                 // =================================================

//                 TextField(
//                   controller:
//                       _passwordController,

//                   obscureText:
//                       _obscurePassword,

//                   textInputAction:
//                       TextInputAction.next,

//                   decoration: _inputDecoration(
//                     hintText: 'Password',
//                     icon: Icons.lock_outline,

//                     suffixIcon: IconButton(
//                       onPressed: () {
//                         setState(() {
//                           _obscurePassword =
//                               !_obscurePassword;
//                         });
//                       },

//                       icon: Icon(
//                         _obscurePassword
//                             ? Icons.visibility_off
//                             : Icons.visibility,
//                         color:
//                             const Color(0xFF756B68),
//                       ),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 18),

//                 // =================================================
//                 // CONFIRM PASSWORD
//                 // =================================================

//                 TextField(
//                   controller:
//                       _confirmPasswordController,

//                   obscureText:
//                       _obscureConfirmPassword,

//                   textInputAction:
//                       TextInputAction.done,

//                   onSubmitted: (_) {
//                     if (!_loading) {
//                       _register();
//                     }
//                   },

//                   decoration: _inputDecoration(
//                     hintText: 'Confirm Password',
//                     icon: Icons.lock_outline,

//                     suffixIcon: IconButton(
//                       onPressed: () {
//                         setState(() {
//                           _obscureConfirmPassword =
//                               !_obscureConfirmPassword;
//                         });
//                       },

//                       icon: Icon(
//                         _obscureConfirmPassword
//                             ? Icons.visibility_off
//                             : Icons.visibility,
//                         color:
//                             const Color(0xFF756B68),
//                       ),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 28),

//                 // =================================================
//                 // CREATE ACCOUNT BUTTON
//                 // =================================================

//                 SizedBox(
//                   width: double.infinity,
//                   height: 55,

//                   child: ElevatedButton(
//                     onPressed:
//                         _loading ? null : _register,

//                     style:
//                         ElevatedButton.styleFrom(
//                       backgroundColor:
//                           const Color(0xFFA94327),

//                       disabledBackgroundColor:
//                           const Color(0xFFD39B89),

//                       foregroundColor:
//                           Colors.white,

//                       shape:
//                           RoundedRectangleBorder(
//                         borderRadius:
//                             BorderRadius.circular(30),
//                       ),
//                     ),

//                     child: _loading
//                         ? const SizedBox(
//                             width: 25,
//                             height: 25,

//                             child:
//                                 CircularProgressIndicator(
//                               strokeWidth: 3,
//                               color: Colors.white,
//                             ),
//                           )
//                         : const Text(
//                             'Create Account',

//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight:
//                                   FontWeight.w600,
//                             ),
//                           ),
//                   ),
//                 ),

//                 const SizedBox(height: 25),

//                 // =================================================
//                 // LOGIN
//                 // =================================================

//                 Row(
//                   mainAxisAlignment:
//                       MainAxisAlignment.center,

//                   children: [
//                     const Text(
//                       'Already have an account? ',

//                       style: TextStyle(
//                         color:
//                             Color(0xFF6E5D57),
//                       ),
//                     ),

//                     GestureDetector(
//                       onTap: () {
//                         Navigator.pushReplacement(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) =>
//                                 const LoginScreen(),
//                           ),
//                         );
//                       },

//                       child: const Text(
//                         'Login',

//                         style: TextStyle(
//                           color:
//                               Color(0xFFA94327),
//                           fontWeight:
//                               FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // INPUT DECORATION
//   // ============================================================

//   InputDecoration _inputDecoration({
//     required String hintText,
//     required IconData icon,
//     Widget? suffixIcon,
//   }) {
//     return InputDecoration(
//       hintText: hintText,

//       prefixIcon: Icon(
//         icon,
//         color: const Color(0xFF756B68),
//       ),

//       suffixIcon: suffixIcon,

//       contentPadding:
//           const EdgeInsets.symmetric(
//         horizontal: 18,
//         vertical: 18,
//       ),

//       enabledBorder:
//           OutlineInputBorder(
//         borderRadius:
//             BorderRadius.circular(12),

//         borderSide:
//             const BorderSide(
//           color: Color(0xFFB99A91),
//           width: 1,
//         ),
//       ),

//       focusedBorder:
//           OutlineInputBorder(
//         borderRadius:
//             BorderRadius.circular(12),

//         borderSide:
//             const BorderSide(
//           color: Color(0xFFA94327),
//           width: 2,
//         ),
//       ),
//     );
//   }
// }








// import 'package:flutter/material.dart';

// import '../services/auth_service.dart';
// import 'home_screen.dart';
// import 'login_screen.dart';

// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});

//   @override
//   State<RegisterScreen> createState() =>
//       _RegisterScreenState();
// }

// class _RegisterScreenState
//     extends State<RegisterScreen> {
//   final _nameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _passwordController =
//       TextEditingController();
//   final _confirmPasswordController =
//       TextEditingController();

//   final _authService = AuthService();

//   bool _loading = false;
//   bool _obscurePassword = true;

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();

//     super.dispose();
//   }

//   Future<void> _register() async {
//     final name = _nameController.text.trim();
//     final email = _emailController.text.trim();
//     final password = _passwordController.text;
//     final confirmPassword =
//         _confirmPasswordController.text;

//     if (name.isEmpty ||
//         email.isEmpty ||
//         password.isEmpty ||
//         confirmPassword.isEmpty) {
//       _showMessage(
//         'Please complete all fields.',
//       );
//       return;
//     }

//     if (password != confirmPassword) {
//       _showMessage(
//         'Passwords do not match.',
//       );
//       return;
//     }

//     if (password.length < 6) {
//       _showMessage(
//         'Password must contain at least 6 characters.',
//       );
//       return;
//     }

//     setState(() {
//       _loading = true;
//     });

//     try {
//       final response =
//           await _authService.register(
//         name: name,
//         email: email,
//         password: password,
//       );

//       if (!mounted) return;

//       if (response.session != null) {
//         Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(
//             builder: (_) => const HomeScreen(),
//           ),
//           (route) => false,
//         );
//       } else {
//         _showMessage(
//           'Registration successful. Please check your email to verify your account.',
//         );

//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (_) => const LoginScreen(),
//           ),
//         );
//       }
//     } catch (e) {
//       _showMessage(
//         'Registration failed. The email may already be registered.',
//       );
//     } finally {
//       if (mounted) {
//         setState(() {
//           _loading = false;
//         });
//       }
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

//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,

//         leading: IconButton(
//           icon: const Icon(
//             Icons.arrow_back,
//             color: Color(0xFFA94327),
//           ),

//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//       ),

//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.fromLTRB(
//             28,
//             10,
//             28,
//             30,
//           ),

//           child: Container(
//             padding: const EdgeInsets.all(30),

//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(28),
//             ),

//             child: Column(
//               children: [
//                 const Icon(
//                   Icons.pets,
//                   size: 50,
//                   color: Color(0xFFA94327),
//                 ),

//                 const SizedBox(height: 15),

//                 const Text(
//                   'Create Account',
//                   style: TextStyle(
//                     fontSize: 30,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF062B35),
//                   ),
//                 ),

//                 const SizedBox(height: 8),

//                 const Text(
//                   'Start your pet adoption journey.',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     color: Color(0xFF6E5D57),
//                   ),
//                 ),

//                 const SizedBox(height: 30),

//                 TextField(
//                   controller: _nameController,
//                   decoration: const InputDecoration(
//                     hintText: 'Full Name',
//                   ),
//                 ),

//                 const SizedBox(height: 18),

//                 TextField(
//                   controller: _emailController,
//                   keyboardType:
//                       TextInputType.emailAddress,
//                   decoration: const InputDecoration(
//                     hintText: 'Email Address',
//                   ),
//                 ),

//                 const SizedBox(height: 18),

//                 TextField(
//                   controller: _passwordController,
//                   obscureText: _obscurePassword,
//                   decoration: InputDecoration(
//                     hintText: 'Password',
//                     suffixIcon: IconButton(
//                       onPressed: () {
//                         setState(() {
//                           _obscurePassword =
//                               !_obscurePassword;
//                         });
//                       },
//                       icon: Icon(
//                         _obscurePassword
//                             ? Icons.visibility_off
//                             : Icons.visibility,
//                       ),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 18),

//                 TextField(
//                   controller:
//                       _confirmPasswordController,
//                   obscureText: _obscurePassword,
//                   decoration: const InputDecoration(
//                     hintText: 'Confirm Password',
//                   ),
//                 ),

//                 const SizedBox(height: 28),

//                 SizedBox(
//                   width: double.infinity,
//                   height: 54,

//                   child: ElevatedButton(
//                     onPressed:
//                         _loading ? null : _register,

//                     style: ElevatedButton.styleFrom(
//                       backgroundColor:
//                           const Color(0xFFA94327),
//                       foregroundColor: Colors.white,

//                       shape: RoundedRectangleBorder(
//                         borderRadius:
//                             BorderRadius.circular(30),
//                       ),
//                     ),

//                     child: _loading
//                         ? const CircularProgressIndicator(
//                             color: Colors.white,
//                           )
//                         : const Text(
//                             'Create Account',
//                             style: TextStyle(
//                               fontWeight:
//                                   FontWeight.w600,
//                             ),
//                           ),
//                   ),
//                 ),

//                 const SizedBox(height: 25),

//                 Row(
//                   mainAxisAlignment:
//                       MainAxisAlignment.center,

//                   children: [
//                     const Text(
//                       'Already have an account? ',
//                     ),

//                     GestureDetector(
//                       onTap: () {
//                         Navigator.pushReplacement(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) =>
//                                 const LoginScreen(),
//                           ),
//                         );
//                       },

//                       child: const Text(
//                         'Login',
//                         style: TextStyle(
//                           color: Color(0xFFA94327),
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }