import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Sistema de diseño de MetrixVox Admin.
/// Coherente con la App Kiosco pero adaptado a web/escritorio.
class AdminTheme {
  // ============================================================
  // COLORES DE MARCA
  // ============================================================
  static const Color indigo = Color(0xFF4F46E5);
  static const Color purple = Color(0xFF7C3AED);
  static const Color emerald = Color(0xFF10B981);
  static const Color amber = Color(0xFFF59E0B);
  static const Color rose = Color(0xFFF43F5E);
  static const Color sky = Color(0xFF0EA5E9);

  // Neutros
  static const Color dark = Color(0xFF0F172A);
  static const Color slate = Color(0xFF1E293B);
  static const Color gray = Color(0xFF64748B);
  static const Color lightGray = Color(0xFFF1F5F9);
  static const Color border = Color(0xFFE2E8F0);
  static const Color white = Colors.white;

  // ============================================================
  // GRADIENTES
  // ============================================================
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [indigo, purple],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [emerald, Color(0xFF059669)],
  );

  // ============================================================
  // TEMA GLOBAL
  // ============================================================
  static ThemeData light() {
    final baseText = GoogleFonts.interTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: indigo,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: lightGray,
      textTheme: baseText.copyWith(
        displayLarge: GoogleFonts.poppins(
          textStyle: baseText.displayLarge,
          fontWeight: FontWeight.w700,
          color: dark,
        ),
        headlineLarge: GoogleFonts.poppins(
          textStyle: baseText.headlineLarge,
          fontWeight: FontWeight.w700,
          color: dark,
        ),
        headlineMedium: GoogleFonts.poppins(
          textStyle: baseText.headlineMedium,
          fontWeight: FontWeight.w600,
          color: dark,
        ),
        titleLarge: GoogleFonts.poppins(
          textStyle: baseText.titleLarge,
          fontWeight: FontWeight.w600,
          color: dark,
        ),
        titleMedium: GoogleFonts.poppins(
          textStyle: baseText.titleMedium,
          fontWeight: FontWeight.w500,
          color: dark,
        ),
        bodyLarge: GoogleFonts.inter(
          textStyle: baseText.bodyLarge,
          fontSize: 16,
          color: dark,
        ),
        bodyMedium: GoogleFonts.inter(
          textStyle: baseText.bodyMedium,
          fontSize: 14,
          color: gray,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: indigo,
          foregroundColor: white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: indigo,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          side: const BorderSide(color: border, width: 1.5),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: indigo, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: GoogleFonts.inter(color: gray.withOpacity(0.6)),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: border),
        ),
        color: white,
      ),
    );
  }
}
