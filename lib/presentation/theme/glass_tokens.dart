import 'package:flutter/material.dart';

class GlassTheme extends ThemeExtension<GlassTheme> {
  final Color fill;
  final Color fillStrong;
  final Color border;
  final Color opaqueSurface;
  final double blurSigma;
  final BoxShadow shadow;

  const GlassTheme({
    required this.fill,
    required this.fillStrong,
    required this.border,
    required this.opaqueSurface,
    required this.blurSigma,
    required this.shadow,
  });

  static GlassTheme light = GlassTheme(
    fill: Colors.white.withValues(alpha: 0.55),
    fillStrong: Colors.white.withValues(alpha: 0.75),
    border: Colors.white.withValues(alpha: 0.70),
    opaqueSurface: Colors.white,
    blurSigma: 18.0,
    shadow: BoxShadow(
      color: const Color(0xFF0F1B2D).withValues(alpha: 0.10),
      offset: const Offset(0, 10),
      blurRadius: 30,
    ),
  );

  static GlassTheme dark = GlassTheme(
    fill: Colors.white.withValues(alpha: 0.10),
    fillStrong: const Color(0xFF16203A).withValues(alpha: 0.85),
    border: Colors.white.withValues(alpha: 0.18),
    opaqueSurface: const Color(0xFF16203A),
    blurSigma: 24.0,
    shadow: BoxShadow(
      color: Colors.black.withValues(alpha: 0.35),
      offset: const Offset(0, 10),
      blurRadius: 30,
    ),
  );

  @override
  ThemeExtension<GlassTheme> copyWith({
    Color? fill,
    Color? fillStrong,
    Color? border,
    Color? opaqueSurface,
    double? blurSigma,
    BoxShadow? shadow,
  }) {
    return GlassTheme(
      fill: fill ?? this.fill,
      fillStrong: fillStrong ?? this.fillStrong,
      border: border ?? this.border,
      opaqueSurface: opaqueSurface ?? this.opaqueSurface,
      blurSigma: blurSigma ?? this.blurSigma,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  ThemeExtension<GlassTheme> lerp(ThemeExtension<GlassTheme>? other, double t) {
    if (other is! GlassTheme) return this;
    return GlassTheme(
      fill: Color.lerp(fill, other.fill, t)!,
      fillStrong: Color.lerp(fillStrong, other.fillStrong, t)!,
      border: Color.lerp(border, other.border, t)!,
      opaqueSurface: Color.lerp(opaqueSurface, other.opaqueSurface, t)!,
      blurSigma: uiLerpDouble(blurSigma, other.blurSigma, t)!,
      shadow: BoxShadow.lerp(shadow, other.shadow, t)!,
    );
  }
}

double? uiLerpDouble(double a, double b, double t) => a + (b - a) * t;
