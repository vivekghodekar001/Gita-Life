import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ═══════════════════════════════════════════════════════════════
//  Sacred Color Palette — Dark parchment & leather tones
// ═══════════════════════════════════════════════════════════════

class SacredColors {
  SacredColors._();

  // Core backgrounds
  static const Color ink = Color(0xFF0B0906);
  static const Color ink2 = Color(0xFF130E0A);
  static const Color surface = Color(0xFF1A120A);
  static const Color surfaceLight = Color(0xFF241A0E);
  static const Color card = Color(0xFF1E1408);

  // Gold / Parchment
  static const Color parchment = Color(0xFFC8A96E);
  static const Color parchmentLight = Color(0xFFE8D5A3);
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldDim = Color(0xFF8B6914);

  // Ash tones
  static const Color ash = Color(0xFF7A6E62);
  static const Color ashLight = Color(0xFFA89E92);

  // Ember accent
  static const Color ember = Color(0xFFC4581A);
  static const Color emberDim = Color(0xFF7A3510);

  // Glass overlays
  static const Color glassBg = Color(0x09FFFFFF);
  static const Color glassBorder = Color(0x2EC8A96E);
  static const Color glassBorderDim = Color(0x14C8A96E);

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

  static TextStyle greeting({double fontSize = 12}) => GoogleFonts.cormorantGaramond(
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w300,
        fontSize: fontSize,
        color: SacredColors.ash,
        letterSpacing: 0.5,
      );

  static TextStyle userName({double fontSize = 22}) => GoogleFonts.cormorantSc(
        fontWeight: FontWeight.w500,
        fontSize: fontSize,
        color: SacredColors.parchmentLight,
        letterSpacing: 1.5,
      );

  static TextStyle sectionLabel({double fontSize = 8}) => GoogleFonts.jost(
        fontWeight: FontWeight.w200,
        fontSize: fontSize,
        letterSpacing: 3.5,
        color: SacredColors.parchment.withOpacity(0.3),
      );

  static TextStyle infoKey({double fontSize = 8}) => GoogleFonts.jost(
        fontWeight: FontWeight.w200,
        fontSize: fontSize,
        letterSpacing: 2,
        color: SacredColors.parchment.withOpacity(0.3),
      );

  static TextStyle infoValue({double fontSize = 14}) => GoogleFonts.cormorantGaramond(
        fontWeight: FontWeight.w400,
        fontSize: fontSize,
        color: SacredColors.parchmentLight.withOpacity(0.75),
      );

  static TextStyle navLabel({double fontSize = 8.5}) => GoogleFonts.jost(
        fontWeight: FontWeight.w300,
        fontSize: fontSize,
        letterSpacing: 1,
        color: SacredColors.parchment.withOpacity(0.4),
      );

  static TextStyle navLabelActive({double fontSize = 8.5}) => GoogleFonts.jost(
        fontWeight: FontWeight.w300,
        fontSize: fontSize,
        letterSpacing: 1,
        color: SacredColors.parchment.withOpacity(0.85),
      );

  static TextStyle bookTitle({double fontSize = 12.5}) => GoogleFonts.cormorantSc(
        fontWeight: FontWeight.w400,
        fontSize: fontSize,
        color: SacredColors.parchment.withOpacity(0.75),
        letterSpacing: 3,
      );

  static TextStyle bookSubtitle({double fontSize = 9}) => GoogleFonts.cormorantGaramond(
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w300,
        fontSize: fontSize,
        color: SacredColors.parchment.withOpacity(0.4),
        letterSpacing: 2,
      );

  static TextStyle verseRef({double fontSize = 9}) => GoogleFonts.jost(
        fontWeight: FontWeight.w200,
        fontSize: fontSize,
        letterSpacing: 4,
        color: SacredColors.parchment.withOpacity(0.35),
      );

  static TextStyle verseDevanagari({double fontSize = 17}) => GoogleFonts.cormorantGaramond(
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w400,
        fontSize: fontSize,
        color: SacredColors.parchment.withOpacity(0.7),
        letterSpacing: 0.3,
        height: 1.9,
      );

  static TextStyle verseTranslation({double fontSize = 15}) => GoogleFonts.cormorantGaramond(
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w300,
        fontSize: fontSize,
        color: SacredColors.parchmentLight.withOpacity(0.65),
        height: 1.8,
      );

  static TextStyle profileName({double fontSize = 20}) => GoogleFonts.cormorantSc(
        fontWeight: FontWeight.w400,
        fontSize: fontSize,
        color: SacredColors.parchmentLight.withOpacity(0.88),
        letterSpacing: 2.5,
      );

  static TextStyle shloka({double fontSize = 12.5}) => GoogleFonts.cormorantGaramond(
        fontStyle: FontStyle.italic,
        fontSize: fontSize,
        color: SacredColors.parchment.withOpacity(0.5),
        letterSpacing: 0.3,
      );

  static TextStyle chip({double fontSize = 11.5}) => GoogleFonts.cormorantGaramond(
        fontSize: fontSize,
        color: SacredColors.parchment.withOpacity(0.55),
      );

  static TextStyle ringPercent({double fontSize = 15}) => GoogleFonts.cormorantSc(
        fontWeight: FontWeight.w500,
        fontSize: fontSize,
      );

  static TextStyle progressLabel({double fontSize = 8}) => GoogleFonts.jost(
        fontWeight: FontWeight.w200,
        fontSize: fontSize,
        letterSpacing: 1.5,
        color: SacredColors.parchment.withOpacity(0.3),
      );
}

// ═══════════════════════════════════════════════════════════════
//  Sacred Decorations — Reusable box decorations
// ═══════════════════════════════════════════════════════════════

class SacredDecorations {
  SacredDecorations._();

  static BoxDecoration glassCard({double radius = 14}) => BoxDecoration(
        color: SacredColors.glassBg,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: SacredColors.glassBorder.withOpacity(0.08)),
      );

  static BoxDecoration glassCardHover({double radius = 14}) => BoxDecoration(
        color: SacredColors.parchment.withOpacity(0.04),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: SacredColors.glassBorder.withOpacity(0.14)),
      );

  static BoxDecoration navPill() => BoxDecoration(
        color: const Color(0x08FFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: SacredColors.parchment.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 32, offset: const Offset(0, 8)),
        ],
      );

  static BoxDecoration iconBox({double radius = 10}) => BoxDecoration(
        color: SacredColors.parchment.withOpacity(0.06),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: SacredColors.parchment.withOpacity(0.1)),
      );

  static BoxDecoration chipDecoration() => BoxDecoration(
        color: SacredColors.parchment.withOpacity(0.05),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: SacredColors.parchment.withOpacity(0.12)),
      );
}
