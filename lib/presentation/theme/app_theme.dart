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
      surface: Colors.white,
      onSurface: AppColors.ink,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: AppColors.ink,
      iconTheme: IconThemeData(color: AppColors.ink),
      titleTextStyle: TextStyle(
        color: AppColors.ink,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: GlassTheme.light.fillStrong,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: GlassTheme.light.border),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: GlassTheme.light.fillStrong,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
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
      surface: const Color(0xFF1E293B),
      onSurface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: GlassTheme.dark.fillStrong,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: GlassTheme.dark.border),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: GlassTheme.dark.fillStrong,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),
    extensions: [GlassTheme.dark],
  );
}
