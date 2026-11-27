import 'dart:ui';
import 'package:flutter/material.dart';
import 'glass_tokens.dart';

class FrostedTile extends StatelessWidget {
  const FrostedTile({
    super.key,
    required this.child,
    this.radius = 20,
    this.onTap,
  });

  final Widget child;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final g = Theme.of(context).extension<GlassTheme>() ??
        (Theme.of(context).brightness == Brightness.dark ? GlassTheme.dark : GlassTheme.light);
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
      ),
    );
  }
}
