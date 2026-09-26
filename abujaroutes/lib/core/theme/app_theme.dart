import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();
  static const Color primary = Color(0xFFFF6B4A);
  static const Color success = Color(0xFF2FB380);
  static const Color warning = Color(0xFFE8A33D);
  static const Color danger = Color(0xFFE24C4C);
  static const Color background = Color(0xFFFBF4EC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFFFF6EE);
  static const Color textPrimary = Color(0xFF241C15);
  static const Color textSecondary = Color(0xFF847A6E);
  static const Color textTertiary = Color(0xFFB9AFA2);
  static const Color border = Color(0xFFEFE4D6);
  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Color(0x14241C15), blurRadius: 20, offset: Offset(0, 8)),
  ];
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF6B4A), Color(0xFFFF8F66)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Transit-mode accent colors used throughout route lists/badges.
  static const Color korope = Color(0xFF6C63FF);
  static const Color keke = Color(0xFFE8A33D);
  static const Color bus = Color(0xFF2FB380);
  static const Color lightRail = Color(0xFF2FA9E8);
}

class AppTextStyles {
  AppTextStyles._();
  static TextStyle get displayLarge => GoogleFonts.plusJakartaSans(fontSize: 40, fontWeight: FontWeight.w800, letterSpacing: -0.8);
  static TextStyle get displayMedium => GoogleFonts.plusJakartaSans(fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.5);
  static TextStyle get displaySmall => GoogleFonts.plusJakartaSans(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.3);
  static TextStyle get headlineLarge => GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w700);
  static TextStyle get headlineMedium => GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.w700);
  static TextStyle get headlineSmall => GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700);
  static TextStyle get bodyLarge => GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w400, height: 1.5);
  static TextStyle get bodyMedium => GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w400, height: 1.5);
  static TextStyle get bodySmall => GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w400, height: 1.5);
  static TextStyle get labelLarge => GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600);
  static TextStyle get labelMedium => GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600);
  static TextStyle get labelSmall => GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.3);
}

class AppTheme {
  AppTheme._();
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      surface: AppColors.surface,
      error: AppColors.danger,
      onPrimary: Colors.white,
      onSurface: AppColors.textPrimary,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: AppTextStyles.headlineMedium.copyWith(color: AppColors.textPrimary),
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        textStyle: AppTextStyles.headlineSmall,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 0.5),
  );
}
