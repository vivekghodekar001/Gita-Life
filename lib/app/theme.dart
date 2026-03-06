import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

<<<<<<< HEAD
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
=======
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
>>>>>>> 99ad060b4b09886d59c8fea80b57098b146f9ed0
    ),
    elevation: 0,
    surfaceTintColor: Colors.transparent,
    iconTheme: IconThemeData(color: gold.withOpacity(0.7), size: 20),
  ),
  cardTheme: CardThemeData(
<<<<<<< HEAD
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: BorderSide(color: gold.withOpacity(0.08)),
=======
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
>>>>>>> 99ad060b4b09886d59c8fea80b57098b146f9ed0
    ),
    color: const Color(0x09FFFFFF),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
<<<<<<< HEAD
      backgroundColor: gold.withOpacity(0.1),
      foregroundColor: gold,
=======
      backgroundColor: krishnaBlue,
      foregroundColor: Colors.white,
>>>>>>> 99ad060b4b09886d59c8fea80b57098b146f9ed0
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
<<<<<<< HEAD
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
=======
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
>>>>>>> 99ad060b4b09886d59c8fea80b57098b146f9ed0
);
