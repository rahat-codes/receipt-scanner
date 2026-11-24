import 'package:flutter/material.dart';

class AuroraBackground extends StatelessWidget {
  const AuroraBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF0B1424), const Color(0xFF1A1F4A), const Color(0xFF0D3A39)]
              : [const Color(0xFFEAF1F6), const Color(0xFFDCDDFF), const Color(0xFFCDF2ED)],
        ),
      ),
      child: Stack(
        children: [
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
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
