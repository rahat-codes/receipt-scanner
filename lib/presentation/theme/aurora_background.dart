import 'package:flutter/material.dart';

class AuroraBackground extends StatelessWidget {
  const AuroraBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
<<<<<<< HEAD

=======
>>>>>>> 81934c3d0910c9ee266a23bdc899ef19ea894423
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
<<<<<<< HEAD
              ? [const Color(0xFF070E1B), const Color(0xFF0F172A), const Color(0xFF131F37)]
              : [const Color(0xFFEBF2F7), const Color(0xFFDCE6F1), const Color(0xFFE2EAF4)],
=======
              ? [const Color(0xFF0B1424), const Color(0xFF1A1F4A), const Color(0xFF0D3A39)]
              : [const Color(0xFFEAF1F6), const Color(0xFFDCDDFF), const Color(0xFFCDF2ED)],
>>>>>>> 81934c3d0910c9ee266a23bdc899ef19ea894423
        ),
      ),
      child: Stack(
        children: [
<<<<<<< HEAD
          // Top-left Lagoon cyan ambient orb
          Positioned(
            top: -120,
            left: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    (isDark ? const Color(0xFF3DD6C6) : const Color(0xFF12B5A6)).withValues(alpha: isDark ? 0.35 : 0.28),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Center-right Iris purple ambient orb
          Positioned(
            top: 140,
            right: -100,
            child: Container(
              width: 340,
              height: 340,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    (isDark ? const Color(0xFF818CF8) : const Color(0xFF7C83FD)).withValues(alpha: isDark ? 0.30 : 0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Bottom-left Sky blue ambient orb
          Positioned(
            bottom: -100,
            left: -60,
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    (isDark ? const Color(0xFF38BDF8) : const Color(0xFF0EA5E9)).withValues(alpha: isDark ? 0.25 : 0.20),
                    Colors.transparent,
                  ],
                ),
=======
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF7C83FD).withValues(alpha: isDark ? 0.3 : 0.25),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF12B5A6).withValues(alpha: isDark ? 0.3 : 0.25),
>>>>>>> 81934c3d0910c9ee266a23bdc899ef19ea894423
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
