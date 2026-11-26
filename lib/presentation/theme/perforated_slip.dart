import 'dart:ui';
import 'package:flutter/material.dart';
import 'glass_tokens.dart';

class PerforatedSlipClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height);
    
    const notchRadius = 6.0;
    const spacing = 18.0;
    double currentX = spacing;
    
    while (currentX < size.width - notchRadius) {
      path.lineTo(currentX - notchRadius, size.height);
      path.arcToPoint(
        Offset(currentX + notchRadius, size.height),
        radius: const Radius.circular(notchRadius),
        clockwise: false,
      );
      currentX += spacing + (notchRadius * 2);
    }
    
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class PerforatedSlip extends StatelessWidget {
  const PerforatedSlip({super.key, required this.child, this.radius = 28});
  final Widget child;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final g = Theme.of(context).extension<GlassTheme>()!;
    final opaque = MediaQuery.of(context).highContrast;
    final fill = opaque ? g.opaqueSurface : g.fillStrong;

    final box = DecoratedBox(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: g.border),
        boxShadow: [g.shadow],
      ),
      child: ClipPath(
        clipper: PerforatedSlipClipper(),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: child,
        ),
      ),
    );

    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: opaque
            ? box
            : BackdropFilter(
                filter: ImageFilter.blur(sigmaX: g.blurSigma, sigmaY: g.blurSigma),
                child: box,
              ),
      ),
    );
  }
}
