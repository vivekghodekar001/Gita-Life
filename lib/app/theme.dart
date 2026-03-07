import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color saffron = Color(0xFFC4581A);
const Color gold = Color(0xFF8B6914);
const Color cream = Color(0xFFE8DCC8);
const Color navy = Color(0xFF3A2010);

final ThemeData gitaLifeTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    primary: saffron,
    secondary: gold,
    surface: const Color(0xFFEDE3CC),
    onSurface: const Color(0xFF3A2010),
    error: const Color(0xFFC45050),
  ),
  scaffoldBackgroundColor: cream,
  textTheme: GoogleFonts.jostTextTheme(ThemeData.light().textTheme).apply(
    bodyColor: navy,
    displayColor: navy,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: const Color(0xFFEDE3CC),
    foregroundColor: const Color(0xFF3A2010),
    titleTextStyle: GoogleFonts.cormorantSc(
      color: const Color(0xFF4A2C0A),
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
      side: BorderSide(color: gold.withOpacity(0.12)),
    ),
    color: const Color(0x22FFFFFF),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: gold.withOpacity(0.12),
      foregroundColor: const Color(0xFF4A2C0A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: gold.withOpacity(0.25)),
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
    fillColor: const Color(0x18FFFFFF),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: gold.withOpacity(0.15)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: gold.withOpacity(0.15)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: gold.withOpacity(0.4), width: 1.5),
    ),
    labelStyle: GoogleFonts.jost(
      color: const Color(0xFF4A2C0A).withOpacity(0.5),
      fontSize: 12,
      fontWeight: FontWeight.w200,
      letterSpacing: 1,
    ),
    hintStyle: TextStyle(color: const Color(0xFF4A2C0A).withOpacity(0.3)),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    selectedItemColor: const Color(0xFF4A2C0A),
    unselectedItemColor: const Color(0xFF4A2C0A).withOpacity(0.4),
    backgroundColor: const Color(0xFFE8DCC8),
  ),
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: Color(0xFF8B4513),
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: const Color(0xFFF5EDDA),
    contentTextStyle: GoogleFonts.jost(color: const Color(0xFF3A2010), fontSize: 13),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    behavior: SnackBarBehavior.floating,
  ),
  dialogTheme: DialogThemeData(
    backgroundColor: const Color(0xFFEDE3CC),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: BorderSide(color: gold.withOpacity(0.15)),
    ),
  ),
  dividerColor: gold.withOpacity(0.12),
  iconTheme: IconThemeData(color: const Color(0xFF4A2C0A).withOpacity(0.5)),
);
