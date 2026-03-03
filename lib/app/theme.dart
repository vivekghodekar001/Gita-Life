import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color saffron = Color(0xFFFF6600);
const Color gold = Color(0xFFD4A017);
const Color cream = Color(0xFFFFF8F0);
const Color navy = Color(0xFF1A1A2E);

final ThemeData gitaLifeTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: saffron,
    primary: saffron,
    secondary: gold,
    surface: cream,
    onSurface: navy,
  ),
  scaffoldBackgroundColor: cream,
  textTheme: GoogleFonts.poppinsTextTheme().apply(
    bodyColor: navy,
    displayColor: navy,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: saffron,
    foregroundColor: Colors.white,
    titleTextStyle: GoogleFonts.poppins(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    elevation: 0,
  ),
  cardTheme: CardThemeData(
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    color: Colors.white,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: saffron,
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
      borderSide: const BorderSide(color: saffron, width: 2),
    ),
    labelStyle: const TextStyle(color: navy),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    selectedItemColor: saffron,
    unselectedItemColor: Colors.grey,
    backgroundColor: Colors.white,
  ),
);
