import 'package:flutter/material.dart';

class AppColors {
  static const lightBackground = Color(0xFFFFF8E1);
  static const lightBackgroundStart = Color(0xFFFFF1CC);
  static const lightBackgroundMiddle = Color(0xFFFFE8A3);
  static const lightBackgroundEnd = Color(0xFFFFDF80);
  // static const lightSurface = Color(0xFFFFF8E1);
  static const lightSurface = Color(0xFFF5E8C7);
  static const lightOnSurface = Color(0xFF3E2723);
  static const lightPrimary = Color(0xFFF4511E);
  static const lightSecondary = Color(0xFF689F38);
  static const lightTextPrimary = Color(0xFF3E2723);
  static const lightTextSecondary = Color(0xFF8D6E63);
  static const lightError = Color(0xFFD32F2F);
  static const lightAccent = Color(0xFF0288D1);

  static const lightBackgroundGradient = RadialGradient(
    center: Alignment(0.2, -0.2),
    colors: [
      lightBackgroundStart,
      lightBackgroundMiddle,
      lightBackgroundEnd,
    ],
  );

  // Dark theme colors
  static const darkBackground = Color(0xFF1A1A1A);
  static const darkBackgroundStart = Color(0xFF262626);
  static const darkBackgroundMiddle = Color(0xFF333F4D);
  static const darkBackgroundEnd = Color(0xFF4D5B6A);

  static const darkSurface = Color(0xFF616161);
  static const darkOnSurface = Color(0xFFFFF9C4);
  static const darkPrimary = Color(0xFFFF7043);
  static const darkSecondary = Color(0xFF81C784);
  static const darkTextPrimary = Color(0xFFFFF9C4);
  static const darkTextSecondary = Color(0xFFBCAAA4);
  static const darkError = Color(0xFFEF5350);
  static const darkAccent = Color(0xFF42A5F5);

  static const darkBackgroundGradient = RadialGradient(
    center: Alignment(-0.2, 0.2),
    colors: [
      darkBackgroundStart,
      darkBackgroundMiddle,
      darkBackgroundEnd,
    ],
  );
}
