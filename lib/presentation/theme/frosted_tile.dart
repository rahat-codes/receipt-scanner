<<<<<<< HEAD
import 'dart:ui';
=======
>>>>>>> 81934c3d0910c9ee266a23bdc899ef19ea894423
import 'package:flutter/material.dart';
import 'glass_tokens.dart';

class FrostedTile extends StatelessWidget {
<<<<<<< HEAD
  const FrostedTile({
    super.key,
    required this.child,
    this.radius = 20,
    this.onTap,
  });

=======
  const FrostedTile({super.key, required this.child, this.radius = 20, this.onTap});
>>>>>>> 81934c3d0910c9ee266a23bdc899ef19ea894423
  final Widget child;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final g = Theme.of(context).extension<GlassTheme>()!;
<<<<<<< HEAD
    final opaque = MediaQuery.of(context).highContrast;
    final fill = opaque ? g.opaqueSurface : g.fill;

    final tileBox = DecoratedBox(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: g.border),
        boxShadow: [g.shadow],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: child,
          ),
        ),
      ),
    );

    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: opaque
            ? tileBox
            : BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: tileBox,
              ),
=======
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radius),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: g.fill,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: g.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: child,
        ),
>>>>>>> 81934c3d0910c9ee266a23bdc899ef19ea894423
      ),
    );
  }
}
