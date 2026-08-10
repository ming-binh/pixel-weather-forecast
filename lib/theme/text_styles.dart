import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

import 'colors.dart';

/// The design's two fonts: 'Pixelify Sans' for numbers/titles/labels
/// without diacritics, 'Be Vietnam Pro' for any Vietnamese text with tone
/// marks and the longer AI-advice copy.
class PixelText {
  PixelText._();

  static TextStyle pixelify({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color color = PixelColors.ink,
    double? letterSpacing,
    List<Shadow>? shadows,
  }) =>
      GoogleFonts.pixelifySans(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        shadows: shadows,
        height: 1,
      );

  static TextStyle beVietnam({
    double fontSize = 13,
    FontWeight fontWeight = FontWeight.w400,
    Color color = PixelColors.ink,
    double? letterSpacing,
    double? height,
  }) =>
      GoogleFonts.beVietnamPro(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );
}
