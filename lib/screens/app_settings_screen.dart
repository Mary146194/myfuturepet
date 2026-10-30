import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/theme_service.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  static const Color primaryColor = Color(0xFFA94327);
  static const Color tealColor = Color(0xFF008F82);

  final SupabaseClient _supabase = Supabase.instance.client;

  String _selectedTheme = 'Light Mode';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _selectedTheme = ThemeService().currentThemeName;
    });
  }

  Future<void> _saveTheme(String theme) async {
    await ThemeService().setTheme(theme);
    setState(() {
      _selectedTheme = theme;
    });
  }

  void _showChangePasswordDialog() {
    final isDark = ThemeService.isDarkMode(context);
    final dialogBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final dialogText = isDark
        ? const Color(0xFFF8FAFC)
        : const Color(0xFF062B35);
    final dialogSubText = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final inputBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final inputBorder = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);

    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscureNew = true;
    bool obscureConfirm = true;
    bool isSubmitting = false;
    String? localError;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: dialogBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF3B1E1E)
                          : const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.lock_reset_rounded,
                      color: Color(0xFFDC2626),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Change Password',
                    style: TextStyle(
                      color: dialogText,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enter your new password below. It will update your account instantly without waiting for an email.',
                      style: TextStyle(
                        color: dialogSubText,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: newPasswordController,
                      obscureText: obscureNew,
                      style: TextStyle(fontSize: 14, color: dialogText),
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        labelStyle: TextStyle(color: dialogSubText),
                        prefixIcon: Icon(
                          Icons.lock_outline_rounded,
                          size: 20,
                          color: dialogSubText,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureNew
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                            color: dialogSubText,
                          ),
                          onPressed: () {
                            setDialogState(() {
                              obscureNew = !obscureNew;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: inputBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: inputBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: primaryColor,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: obscureConfirm,
                      style: TextStyle(fontSize: 14, color: dialogText),
                      decoration: InputDecoration(
                        labelText: 'Confirm New Password',
                        labelStyle: TextStyle(color: dialogSubText),
                        prefixIcon: Icon(
                          Icons.lock_outline_rounded,
                          size: 20,
                          color: dialogSubText,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureConfirm
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                            color: dialogSubText,
                          ),
                          onPressed: () {
                            setDialogState(() {
                              obscureConfirm = !obscureConfirm;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: inputBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: inputBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: primaryColor,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    if (localError != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFECACA)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 16,
                              color: Color(0xFFDC2626),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                localError!,
                                style: const TextStyle(
                                  color: Color(0xFFDC2626),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton.icon(
                        icon: const Icon(
                          Icons.mail_outline_rounded,
                          size: 16,
                          color: tealColor,
                        ),
                        label: const Text(
                          'Send reset link to email instead',
                          style: TextStyle(
                            fontSize: 12,
                            color: tealColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                final email = _supabase.auth.currentUser?.email;
                                if (email == null || email.isEmpty) {
                                  setDialogState(() {
                                    localError =
                                        'No authenticated email found.';
                                  });
                                  return;
                                }
                                Navigator.pop(dialogCtx);
                                try {
                                  await _supabase.auth.resetPasswordForEmail(
                                    email,
                                  );
                                  if (mounted) {
                                    ScaffoldMessenger.of(
                                      this.context,
                                    ).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Password reset link sent to $email',
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(
                                      this.context,
                                    ).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Failed to send email: $e',
                                        ),
                                        backgroundColor: Colors.red.shade700,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                }
                              },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () => Navigator.pop(dialogCtx),
                  child: Text('Cancel', style: TextStyle(color: dialogSubText)),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final newPass = newPasswordController.text.trim();
                          final confirmPass = confirmPasswordController.text
                              .trim();

                          if (newPass.isEmpty) {
                            setDialogState(() {
                              localError = 'Please enter a new password.';
                            });
                            return;
                          }
                          if (newPass.length < 6) {
                            setDialogState(() {
                              localError =
                                  'Password must be at least 6 characters.';
                            });
                            return;
                          }
                          if (newPass != confirmPass) {
                            setDialogState(() {
                              localError = 'Passwords do not match.';
                            });
                            return;
                          }

                          setDialogState(() {
                            isSubmitting = true;
                            localError = null;
                          });

                          try {
                            await _supabase.auth.updateUser(
                              UserAttributes(password: newPass),
                            );
                            if (dialogCtx.mounted) {
                              Navigator.pop(dialogCtx);
                            }
                            if (mounted) {
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                SnackBar(
                                  content: const Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle_rounded,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 8),
                                      Text('Password updated successfully!'),
                                    ],
                                  ),
                                  backgroundColor: Colors.green.shade700,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          } catch (e) {
                            setDialogState(() {
                              isSubmitting = false;
                              localError = e.toString().replaceFirst(
                                'Exception: ',
                                '',
                              );
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Update Password',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showInfoDialog(String title, String content) {
    final isDark = ThemeService.isDarkMode(context);
    final dialogBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final dialogText = isDark
        ? const Color(0xFFF8FAFC)
        : const Color(0xFF062B35);
    final dialogSubText = isDark
        ? const Color(0xFFCBD5E1)
        : const Color(0xFF475569);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: dialogBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: dialogText,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Text(
              content,
              style: TextStyle(color: dialogSubText, fontSize: 13, height: 1.5),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeService.isDarkMode(context);
    final bgCol = isDark ? const Color(0xFF0F172A) : const Color(0xFFF5FAFD);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textCol = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF062B35);
    final subTextCol = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final borderCol = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);
    final appBarBg = isDark ? const Color(0xFF1E293B) : Colors.white;

    final user = _supabase.auth.currentUser;
    final userEmail = user?.email ?? 'adopter@myfuturepet.org';

    return Scaffold(
      backgroundColor: bgCol,
      appBar: AppBar(
        backgroundColor: appBarBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: textCol,
            size: 19,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'App Settings',
          style: TextStyle(
            color: textCol,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: borderCol, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================================================
            // ACCOUNT & SECURITY
            // ==================================================
            _buildSectionHeader(
              'Account & Security',
              Icons.person_outline,
              textCol,
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: borderCol),
              ),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    leading: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E3A8A).withValues(alpha: 0.4)
                            : const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.alternate_email_rounded,
                        color: Color(0xFF3B82F6),
                        size: 20,
                      ),
                    ),
                    title: Text(
                      'Account Email',
                      style: TextStyle(
                        color: textCol,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      userEmail,
                      style: TextStyle(color: subTextCol, fontSize: 12),
                    ),
                  ),
                  Divider(height: 1, color: borderCol),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    leading: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF7F1D1D).withValues(alpha: 0.4)
                            : const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.lock_reset_rounded,
                        color: Color(0xFFEF4444),
                        size: 20,
                      ),
                    ),
                    title: Text(
                      'Change Password',
                      style: TextStyle(
                        color: textCol,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Update your account password',
                      style: TextStyle(color: subTextCol, fontSize: 12),
                    ),
                    trailing: Icon(Icons.chevron_right, color: subTextCol),
                    onTap: _showChangePasswordDialog,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ==================================================
            // APPEARANCE & DISPLAY
            // ==================================================
            _buildSectionHeader(
              'Appearance & Display',
              Icons.palette_outlined,
              textCol,
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: borderCol),
              ),
              child: Column(
                children: [
                  _buildThemeOption(
                    'Light Mode',
                    Icons.light_mode_outlined,
                    textCol: textCol,
                    unselectedIconCol: subTextCol,
                  ),
                  Divider(height: 1, color: borderCol),
                  _buildThemeOption(
                    'Dark Mode',
                    Icons.dark_mode_outlined,
                    textCol: textCol,
                    unselectedIconCol: subTextCol,
                  ),
                  Divider(height: 1, color: borderCol),
                  _buildThemeOption(
                    'System Default',
                    Icons.brightness_auto_outlined,
                    textCol: textCol,
                    unselectedIconCol: subTextCol,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ==================================================
            // ABOUT & POLICIES
            // ==================================================
            _buildSectionHeader(
              'About Application',
              Icons.info_outline,
              textCol,
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: borderCol),
              ),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    leading: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF0369A1).withValues(alpha: 0.4)
                            : const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.privacy_tip_outlined,
                        color: Color(0xFF0284C7),
                        size: 20,
                      ),
                    ),
                    title: Text(
                      'Privacy Policy',
                      style: TextStyle(
                        color: textCol,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: Icon(Icons.chevron_right, color: subTextCol),
                    onTap: () {
                      _showInfoDialog(
                        'Privacy Policy',
                        'My Future Pet values your privacy. We collect basic contact details, submitted adoption questions, and optional location information solely for screening adoption applications with licensed partner shelters.\n\nYour data is securely stored in Supabase with row-level security and is never sold to third-party advertisers.',
                      );
                    },
                  ),
                  Divider(height: 1, color: borderCol),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    leading: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF78350F).withValues(alpha: 0.4)
                            : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.description_outlined,
                        color: Color(0xFFD97706),
                        size: 20,
                      ),
                    ),
                    title: Text(
                      'Terms of Service',
                      style: TextStyle(
                        color: textCol,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: Icon(Icons.chevron_right, color: subTextCol),
                    onTap: () {
                      _showInfoDialog(
                        'Terms of Service',
                        'By using My Future Pet, you agree to submit truthful information during the adoption screening process. Adopted pets must receive proper nutrition, healthcare, and safe shelter.\n\nAdoption applications are reviewed by shelter staff to ensure a loving, compatible home for each rescue animal.',
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color textCol) {
    return Row(
      children: [
        Icon(icon, size: 17, color: primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: textCol,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildThemeOption(
    String label,
    IconData icon, {
    required Color textCol,
    required Color unselectedIconCol,
  }) {
    final bool isSelected = _selectedTheme == label;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Icon(
        icon,
        color: isSelected ? primaryColor : unselectedIconCol,
        size: 20,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: textCol,
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded, color: tealColor, size: 20)
          : null,
      onTap: () => _saveTheme(label),
    );
  }
}
