import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'glass_tokens.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.transparent,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.lagoon,
      brightness: Brightness.light,
      primary: AppColors.lagoon,
      secondary: AppColors.iris,
    ),
    extensions: [GlassTheme.light],
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.transparent,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.lagoonDark,
      brightness: Brightness.dark,
      primary: AppColors.lagoonDark,
      secondary: AppColors.iris,
    ),
    extensions: [GlassTheme.dark],
  );
}
