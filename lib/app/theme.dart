import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color saffron = Color(0xFFC4581A);
const Color gold = Color(0xFFC8A96E);
const Color cream = Color(0xFF080604);
const Color navy = Color(0xFFE8D5A3);

final ThemeData gitaLifeTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    primary: saffron,
    secondary: gold,
    surface: const Color(0xFF1A120A),
    onSurface: const Color(0xFFE8D5A3),
    error: const Color(0xFFC45050),
  ),
  scaffoldBackgroundColor: cream,
  textTheme: GoogleFonts.jostTextTheme(ThemeData.dark().textTheme).apply(
    bodyColor: navy,
    displayColor: navy,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: const Color(0xFF130E0A),
    foregroundColor: const Color(0xFFE8D5A3),
    titleTextStyle: GoogleFonts.cormorantSc(
      color: const Color(0xFFC8A96E),
      fontSize: 18,
      fontWeight: FontWeight.w500,
      letterSpacing: 2,
    ),
    elevation: 0,
    surfaceTintColor: Colors.transparent,
    iconTheme: IconThemeData(color: gold.withOpacity(0.7), size: 20),
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: BorderSide(color: gold.withOpacity(0.08)),
    ),
    color: const Color(0x09FFFFFF),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: gold.withOpacity(0.1),
      foregroundColor: gold,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: gold.withOpacity(0.2)),
      ),
      elevation: 0,
      textStyle: GoogleFonts.jost(
        fontWeight: FontWeight.w300,
        letterSpacing: 2,
        fontSize: 12,
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0x09FFFFFF),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: gold.withOpacity(0.08)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: gold.withOpacity(0.08)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: gold.withOpacity(0.3), width: 1.5),
    ),
    labelStyle: GoogleFonts.jost(
      color: gold.withOpacity(0.3),
      fontSize: 12,
      fontWeight: FontWeight.w200,
      letterSpacing: 1,
    ),
    hintStyle: TextStyle(color: gold.withOpacity(0.2)),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    selectedItemColor: gold,
    unselectedItemColor: gold.withOpacity(0.3),
    backgroundColor: const Color(0xFF0B0906),
  ),
  progressIndicatorTheme: ProgressIndicatorThemeData(
    color: gold.withOpacity(0.6),
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: const Color(0xFF1A120A),
    contentTextStyle: GoogleFonts.jost(color: const Color(0xFFE8D5A3), fontSize: 13),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    behavior: SnackBarBehavior.floating,
  ),
  dialogTheme: DialogThemeData(
    backgroundColor: const Color(0xFF130E0A),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: BorderSide(color: gold.withOpacity(0.1)),
    ),
  ),
  dividerColor: gold.withOpacity(0.08),
  iconTheme: IconThemeData(color: gold.withOpacity(0.5)),
);
