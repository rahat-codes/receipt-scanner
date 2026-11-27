import 'dart:ui';
import 'package:flutter/material.dart';
import 'glass_tokens.dart';

class GlassPanel extends StatelessWidget {
  const GlassPanel({super.key, required this.child, this.radius = 20, this.strong = false});
  final Widget child; final double radius; final bool strong;

  @override
  Widget build(BuildContext context) {
    final g = Theme.of(context).extension<GlassTheme>() ??
        (Theme.of(context).brightness == Brightness.dark ? GlassTheme.dark : GlassTheme.light);
    // WHY: opaque surface when the user asked for high contrast; blur hurts legibility for some users.
    final opaque = MediaQuery.of(context).highContrast;
    final fill = opaque ? g.opaqueSurface : (strong ? g.fillStrong : g.fill);
    final box = DecoratedBox(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: g.border),
        boxShadow: [g.shadow],
      ),
      child: child,
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
