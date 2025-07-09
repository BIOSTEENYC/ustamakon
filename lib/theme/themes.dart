// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

ThemeData lightTheme(BuildContext context, {Color? customPrimary}) {
  final primaryColor = customPrimary ?? AppColors.primaryLight;
  return ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      onPrimary: primaryColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
      secondary: AppColors.secondaryLight,
      onSecondary: AppColors.onSecondaryLight,
      surface: AppColors.surfaceLight,
      onSurface: AppColors.onSurfaceLight,
      error: Colors.red.shade700,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: AppColors.backgroundLight,
    textTheme: GoogleFonts.montserratTextTheme(Theme.of(context).textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: primaryColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: primaryColor),
      titleTextStyle: GoogleFonts.montserrat(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: primaryColor,
      ),
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      color: Color.fromRGBO(255, 255, 255, 0.2),
      shadowColor: Colors.black26,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      elevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Color.fromRGBO(255, 255, 255, 0.1),
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      elevation: 16,
      type: BottomNavigationBarType.fixed,
    ),
  );
}

ThemeData darkTheme(BuildContext context, {Color? customPrimary}) {
  final primaryColor = customPrimary ?? AppColors.primaryDark;
  return ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      onPrimary: primaryColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
      secondary: AppColors.secondaryDark,
      onSecondary: AppColors.onSecondaryDark,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.onSurfaceDark,
      error: Colors.red.shade400,
      onError: Colors.black,
    ),
    scaffoldBackgroundColor: AppColors.backgroundDark,
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: primaryColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
      elevation: 8,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
      ),
      titleTextStyle: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: primaryColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: AppColors.surfaceDark,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
    ),
    textTheme: GoogleFonts.interTextTheme(
      Theme.of(context).textTheme.apply(
        bodyColor: AppColors.onBackgroundDark,
        displayColor: AppColors.onBackgroundDark,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.secondaryDark,
      foregroundColor: AppColors.onSecondaryDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    buttonTheme: ButtonThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: primaryColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.onSurfaceDark.withOpacity(0.3), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      labelStyle: GoogleFonts.inter(color: AppColors.onSurfaceDark.withOpacity(0.7)),
      hintStyle: GoogleFonts.inter(color: AppColors.onSurfaceDark.withOpacity(0.5)),
    ),
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.surfaceDark,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: AppColors.surfaceDark,
    ),
  );
}
