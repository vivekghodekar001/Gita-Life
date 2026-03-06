import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color krishnaBlue = Color(0xFF1565C0);
const Color peacockTeal = Color(0xFF00695C);
const Color iridescent = Color(0xFF00ACC1);
const Color softMist = Color(0xFFE8F5F9);
const Color deepNight = Color(0xFF0D1B2A);
const Color peacockGreen = Color(0xFF2E7D32);
const Color royalPurple = Color(0xFF4527A0);

final ThemeData gitaLifeTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: krishnaBlue,
    primary: krishnaBlue,
    secondary: peacockTeal,
    tertiary: iridescent,
    surface: softMist,
    onSurface: deepNight,
  ),
  scaffoldBackgroundColor: softMist,
  textTheme: GoogleFonts.poppinsTextTheme().apply(
    bodyColor: deepNight,
    displayColor: deepNight,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: krishnaBlue,
    foregroundColor: Colors.white,
    titleTextStyle: GoogleFonts.poppins(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    elevation: 0,
  ),
  cardTheme: CardThemeData(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    color: Colors.white,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: krishnaBlue,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: krishnaBlue, width: 2),
    ),
    labelStyle: const TextStyle(color: peacockTeal),
    prefixIconColor: peacockTeal,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    selectedItemColor: krishnaBlue,
    unselectedItemColor: Colors.grey,
    backgroundColor: Colors.white,
  ),
  chipTheme: ChipThemeData(
    selectedColor: krishnaBlue.withOpacity(0.2),
    checkmarkColor: krishnaBlue,
  ),
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: krishnaBlue,
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return krishnaBlue;
      return null;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return krishnaBlue.withOpacity(0.4);
      return null;
    }),
  ),
  sliderTheme: const SliderThemeData(
    activeTrackColor: krishnaBlue,
    thumbColor: krishnaBlue,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: krishnaBlue,
    foregroundColor: Colors.white,
  ),
);
