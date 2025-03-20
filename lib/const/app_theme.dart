import 'package:flutter/material.dart';
import 'package:reels/const/app_colors.dart';
import 'package:reels/const/app_value.dart';

class AppTheme {
  static ThemeData light = ThemeData(
    primaryColor: AppColors.lightPrimary,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 4,
      ),
    ),
    dividerTheme: DividerThemeData(color: AppColors.lightSurface),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
    ),
    scaffoldBackgroundColor: AppColors.lightBackground,
    textTheme: TextTheme(
      titleLarge:
          TextStyle(fontSize: AppValue.size.xxl, color: AppColors.lightPrimary),
      titleMedium:
          TextStyle(fontSize: AppValue.size.xl, color: AppColors.lightPrimary),
      bodyLarge: TextStyle(
          fontSize: AppValue.size.l, color: AppColors.lightTextPrimary),
      bodyMedium: TextStyle(
          fontSize: AppValue.size.m, color: AppColors.lightTextPrimary),
      bodySmall: TextStyle(
          fontSize: AppValue.size.s, color: AppColors.lightTextSecondary),
    ),
    colorScheme: const ColorScheme.light(
      primary: AppColors.lightPrimary,
      secondary: AppColors.lightAccent,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightOnSurface,
      error: AppColors.lightError,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onError: Colors.white,
    ),
  );

  static ThemeData dark = ThemeData(
    primaryColor: AppColors.darkPrimary,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 4,
      ),
    ),
    dividerTheme: DividerThemeData(
      color: AppColors.darkOnSurface,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    textTheme: TextTheme(
      titleLarge:
          TextStyle(fontSize: AppValue.size.xxl, color: AppColors.darkPrimary),
      titleMedium:
          TextStyle(fontSize: AppValue.size.xl, color: AppColors.darkPrimary),
      //title content
      bodyLarge: TextStyle(
          fontSize: AppValue.size.l, color: AppColors.darkTextPrimary),
      //content
      bodyMedium: TextStyle(
          fontSize: AppValue.size.m, color: AppColors.darkTextPrimary),
      //description
      bodySmall: TextStyle(
          fontSize: AppValue.size.s, color: AppColors.darkTextSecondary),
    ),
    colorScheme: const ColorScheme.dark(
      primary: AppColors.darkPrimary,
      secondary: AppColors.darkAccent,
      // secondary: AppColors.darkSecondary,
      surface: AppColors.darkSurface,
      error: AppColors.darkError,
      onError: Colors.black,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: AppColors.darkOnSurface,
    ),
  );
}
