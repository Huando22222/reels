// import 'package:flutter/material.dart';

// class AppColors {
//   static const Color lightBackground = Color(0xFFECEFF1);
//   static const Color lightSurface = Color(0xFFF5F7FA);
//   static const Color lightPrimary = Color(0xFF455A64);
//   static const Color lightSecondary = Color(0xFFF06292);
//   static const Color lightTextPrimary = Color(0xFF263238);
//   static const Color lightTextSecondary = Color(0xFF78909C);
//   static const Color lightError = Color(0xFFE53935);
//   static const Color lightAccent = Color(0xFFFF8F00);

//   static const Color darkBackground = Color(0xFF212121);
//   static const Color darkSurface = Color(0xFF2E2E2E);
//   static const Color darkPrimary = Color(0xFF90A4AE);
//   static const Color darkSecondary = Color(0xFFFF7043);
//   static const Color darkTextPrimary = Color(0xFFECEFF1);
//   static const Color darkTextSecondary = Color(0xFFB0BEC5);
//   static const Color darkError = Color(0xFFEF5350);
//   static const Color darkAccent = Color(0xFFFFCA28);
// }

import 'package:flutter/material.dart';

// Define color constants
// class AppColors {
//   // Light theme colors
//   static const lightBackgroundStart = Color(0xFFF5F7FA);
//   static const lightBackgroundEnd = Color(0xFFE4E9F2);
//   static const lightSurface = Color(0xFFFFFFFF);
//   static const lightPrimary = Color(0xFF007AFF);
//   static const lightSecondary = Color(0xFF5856D6);
//   static const lightTextPrimary = Color(0xFF1C2526);
//   static const lightTextSecondary = Color(0xFF8E8E93);
//   static const lightError = Color(0xFFFF3B30);
//   static const lightAccent = Color(0xFF34C759);

//   // Dark theme colors
//   static const darkBackgroundStart = Color(0xFF1C2526);
//   static const darkBackgroundEnd = Color(0xFF2C3539);
//   static const darkSurface = Color(0xFF2C3539);
//   static const darkPrimary = Color(0xFF0A84FF);
//   static const darkSecondary = Color(0xFF5E5CE6);
//   static const darkTextPrimary = Color(0xFFFFFFFF);
//   static const darkTextSecondary = Color(0xFF8E8E93);
//   static const darkError = Color(0xFFFF453A);
//   static const darkAccent = Color(0xFF30D158);
// }
class AppColors {
  static const lightBackground = Color(0xFFFFF8E1);
  static const lightBackgroundStart = Color(0xFFFFF1CC);
  static const lightBackgroundMiddle = Color(0xFFFFE8A3);
  static const lightBackgroundEnd = Color(0xFFFFDF80);
  static const lightSurface = Color(0xFFFFF8E1);
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
