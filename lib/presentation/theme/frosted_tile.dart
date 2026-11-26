import 'package:flutter/material.dart';
import 'glass_tokens.dart';

class FrostedTile extends StatelessWidget {
  const FrostedTile({super.key, required this.child, this.radius = 20, this.onTap});
  final Widget child;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final g = Theme.of(context).extension<GlassTheme>()!;
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
      ),
    );
  }
}
