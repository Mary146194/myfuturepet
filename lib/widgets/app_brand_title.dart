import 'package:flutter/material.dart';

import '../services/theme_service.dart';

/// Logo + "My Future Pet" shown at the top left of every main tab.
class AppBrandTitle extends StatelessWidget {
  final VoidCallback? onTap;

  const AppBrandTitle({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeService.isDarkMode(context);

    return Semantics(
      button: onTap != null,
      label: 'My Future Pet, go to Home',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8EA),
                    width: 1,
                  ),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/app_launcher_icon.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'My Future Pet',
                style: TextStyle(
                  color: Color(0xFFA94327),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
