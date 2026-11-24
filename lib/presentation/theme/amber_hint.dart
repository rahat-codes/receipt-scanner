import 'package:flutter/material.dart';
import 'app_colors.dart';

class AmberHint extends StatelessWidget {
  const AmberHint({super.key, required this.child, required this.message});
  final Widget child;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.amber, width: 1.5),
            borderRadius: BorderRadius.circular(14),
          ),
          child: child,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.amber),
            const SizedBox(width: 4),
            Text(
              message,
              style: const TextStyle(fontSize: 12, color: AppColors.amber, fontWeight: FontWeight.w500),
            ),
          ],
        )
      ],
    );
  }
}
