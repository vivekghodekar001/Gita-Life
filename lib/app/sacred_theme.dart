import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ═══════════════════════════════════════════════════════════════
//  Sacred Color Palette — Dark parchment & leather tones
// ═══════════════════════════════════════════════════════════════

class SacredColors {
  SacredColors._();

  // Core backgrounds — warm parchment
  static const Color ink = Color(0xFFE8DCC8);
  static const Color ink2 = Color(0xFFE0D0B0);
  static const Color surface = Color(0xFFD4C49A);
  static const Color surfaceLight = Color(0xFFEDE3CC);
  static const Color card = Color(0xFFF5EDDA);

  // Primary text / foreground — dark brown on parchment
  static const Color parchment = Color(0xFF4A2C0A);
  static const Color parchmentLight = Color(0xFF3A2010);
  static const Color gold = Color(0xFF8B6914);
  static const Color goldDim = Color(0xFFB89530);

  // Ash tones
  static const Color ash = Color(0xFF5C4A38);
  static const Color ashLight = Color(0xFF7A6A58);

  // Ember accent
  static const Color ember = Color(0xFFC4581A);
  static const Color emberDim = Color(0xFF7A3510);

  // Glass overlays — cream glass on parchment
  static const Color glassBg = Color(0x55EDE3CC);
  static const Color glassBorder = Color(0x508B6914);
  static const Color glassBorderDim = Color(0x308B6914);

  // White at various opacities
  static const Color white5 = Color(0x0DFFFFFF);
  static const Color white10 = Color(0x1AFFFFFF);
  static const Color white20 = Color(0x33FFFFFF);

  // Leather tones for book
  static const Color leather1 = Color(0xFF2C1606);
  static const Color leather2 = Color(0xFF3D2008);
  static const Color leather3 = Color(0xFF4A2A0A);
  static const Color leatherDark = Color(0xFF1E1006);
  static const Color spineColor = Color(0xFF0E0804);

  // Page edge
  static const Color pageEdge = Color(0xFFE8D5B0);
  static const Color pageEdgeDark = Color(0xFFB89E60);
}

// ═══════════════════════════════════════════════════════════════
//  Sacred Typography
// ═══════════════════════════════════════════════════════════════

class SacredTextStyles {
  SacredTextStyles._();

  static TextStyle greeting({double fontSize = 13}) => GoogleFonts.cormorantGaramond(
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w500,
        fontSize: fontSize,
        color: SacredColors.ash,
        letterSpacing: 0.5,
      );

  static TextStyle userName({double fontSize = 25}) => GoogleFonts.cormorantSc(
        fontWeight: FontWeight.w500,
        fontSize: fontSize,
        color: SacredColors.parchmentLight,
        letterSpacing: 1.5,
      );

  static TextStyle sectionLabel({double fontSize = 10}) => GoogleFonts.jost(
        fontWeight: FontWeight.w500,
        fontSize: fontSize,
        letterSpacing: 3.5,
        color: SacredColors.parchment.withOpacity(0.58),
      );

  static TextStyle infoKey({double fontSize = 10}) => GoogleFonts.jost(
        fontWeight: FontWeight.w500,
        fontSize: fontSize,
        letterSpacing: 2,
        color: SacredColors.parchment.withOpacity(0.55),
      );

  static TextStyle infoValue({double fontSize = 15}) => GoogleFonts.cormorantGaramond(
        fontWeight: FontWeight.w600,
        fontSize: fontSize,
        color: SacredColors.parchmentLight.withOpacity(0.90),
      );

  static TextStyle navLabel({double fontSize = 10}) => GoogleFonts.jost(
        fontWeight: FontWeight.w500,
        fontSize: fontSize,
        letterSpacing: 1,
        color: SacredColors.parchment.withOpacity(0.62),
      );

  static TextStyle navLabelActive({double fontSize = 10}) => GoogleFonts.jost(
        fontWeight: FontWeight.w700,
        fontSize: fontSize,
        letterSpacing: 1,
        color: SacredColors.parchment.withOpacity(0.95),
      );

  static TextStyle bookTitle({double fontSize = 12.5}) => GoogleFonts.cormorantSc(
        fontWeight: FontWeight.w700,
        fontSize: fontSize,
        color: const Color(0xFFD4AF37),
        letterSpacing: 3,
        shadows: [
          Shadow(
            color: Color(0xFFD4AF37),
            blurRadius: 8,
          ),
        ],
      );

  static TextStyle bookSubtitle({double fontSize = 11}) => GoogleFonts.cormorantGaramond(
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w700,
        fontSize: fontSize,
        color: const Color(0xFFD4AF37),
        letterSpacing: 2,
        shadows: const [Shadow(color: Color(0xFFD4AF37), blurRadius: 6)],
      );

  static TextStyle verseRef({double fontSize = 11}) => GoogleFonts.jost(
        fontWeight: FontWeight.w500,
        fontSize: fontSize,
        letterSpacing: 4,
        color: SacredColors.parchment.withOpacity(0.60),
      );

  static TextStyle verseDevanagari({double fontSize = 17}) => GoogleFonts.cormorantGaramond(
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w600,
        fontSize: fontSize,
        color: SacredColors.parchment.withOpacity(0.88),
        letterSpacing: 0.3,
        height: 1.9,
      );

  static TextStyle verseTranslation({double fontSize = 15}) => GoogleFonts.cormorantGaramond(
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w500,
        fontSize: fontSize,
        color: SacredColors.parchmentLight.withOpacity(0.82),
        height: 1.8,
      );

  static TextStyle profileName({double fontSize = 20}) => GoogleFonts.cormorantSc(
        fontWeight: FontWeight.w400,
        fontSize: fontSize,
        color: SacredColors.parchmentLight.withOpacity(0.88),
        letterSpacing: 2.5,
      );

  static TextStyle shloka({double fontSize = 14}) => GoogleFonts.cormorantGaramond(
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w600,
        fontSize: fontSize,
        color: SacredColors.parchment.withOpacity(0.75),
        letterSpacing: 0.3,
      );

  static TextStyle chip({double fontSize = 13}) => GoogleFonts.cormorantGaramond(
        fontWeight: FontWeight.w600,
        fontSize: fontSize,
        color: SacredColors.parchment.withOpacity(0.80),
      );

  static TextStyle ringPercent({double fontSize = 15}) => GoogleFonts.cormorantSc(
        fontWeight: FontWeight.w500,
        fontSize: fontSize,
      );

  static TextStyle progressLabel({double fontSize = 10}) => GoogleFonts.jost(
        fontWeight: FontWeight.w500,
        fontSize: fontSize,
        letterSpacing: 1.5,
        color: SacredColors.parchment.withOpacity(0.62),
      );
}

// ═══════════════════════════════════════════════════════════════
//  Sacred Decorations — Reusable box decorations
// ═══════════════════════════════════════════════════════════════

class SacredDecorations {
  SacredDecorations._();

  static BoxDecoration glassCard({double radius = 14}) => BoxDecoration(
        color: const Color(0x50EDE3CC),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: const Color(0xFF8B6914).withOpacity(0.35), width: 1),
      );

  static BoxDecoration glassCardHover({double radius = 14}) => BoxDecoration(
        color: SacredColors.parchment.withOpacity(0.10),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: SacredColors.glassBorder.withOpacity(0.30)),
      );

  static BoxDecoration navPill() => BoxDecoration(
        color: const Color(0xDDF5EDDA),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: SacredColors.parchment.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(color: const Color(0xFF8B6914).withOpacity(0.12), blurRadius: 24, offset: const Offset(0, 6)),
        ],
      );

  static BoxDecoration iconBox({double radius = 10}) => BoxDecoration(
        color: const Color(0xFF8B6914).withOpacity(0.12),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: const Color(0xFF8B6914).withOpacity(0.25)),
      );

  static BoxDecoration chipDecoration() => BoxDecoration(
        color: const Color(0xFF8B4513).withOpacity(0.08),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFF8B4513).withOpacity(0.25)),
      );
}
