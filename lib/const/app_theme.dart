import 'package:flutter/material.dart';
import 'package:reels/const/app_colors.dart';
import 'package:reels/const/app_value.dart';

class AppTheme {
  static ThemeData light = ThemeData(
    primaryColor: AppColors.lightPrimary,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lightPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
    ),
    scaffoldBackgroundColor: AppColors.lightBackground,
    textTheme: TextTheme(
      titleLarge: TextStyle(
          fontSize: AppValue.size.xxl, color: AppColors.lightSecondary),
      titleMedium:
          TextStyle(fontSize: AppValue.size.xl, color: AppColors.lightAccent),
      bodyLarge: TextStyle(
          fontSize: AppValue.size.l, color: AppColors.lightTextPrimary),
      bodyMedium: TextStyle(
          fontSize: AppValue.size.m, color: AppColors.lightTextPrimary),
      bodySmall: TextStyle(
          fontSize: AppValue.size.s, color: AppColors.lightTextSecondary),
    ),
    colorScheme: const ColorScheme.light(
      primary: AppColors.lightPrimary,
      secondary: AppColors.lightSecondary,
      surface: AppColors.lightSurface,
      error: AppColors.lightError,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: AppColors.lightTextPrimary,
      onError: Colors.white,
    ),
  );

  static ThemeData dark = ThemeData(
    primaryColor: AppColors.darkPrimary,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkPrimary,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    textTheme: TextTheme(
      titleLarge:
          TextStyle(fontSize: AppValue.size.xxl, color: AppColors.darkAccent),
      titleMedium:
          TextStyle(fontSize: AppValue.size.xl, color: AppColors.darkAccent),
      bodyLarge: TextStyle(
          fontSize: AppValue.size.l, color: AppColors.darkTextPrimary),
      bodyMedium: TextStyle(
          fontSize: AppValue.size.m, color: AppColors.darkTextPrimary),
      bodySmall: TextStyle(
          fontSize: AppValue.size.s, color: AppColors.darkTextSecondary),
    ),
    colorScheme: const ColorScheme.dark(
      primary: AppColors.darkPrimary,
      secondary: AppColors.darkSecondary,
      surface: AppColors.darkSurface,
      error: AppColors.darkError,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: AppColors.darkTextPrimary,
      onError: Colors.black,
    ),
  );
}
