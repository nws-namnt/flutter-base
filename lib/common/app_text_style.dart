import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Reusable [TextStyle] definitions built on the Source Code Pro font family.
class AppTextStyle {
  /// Base Source Code Pro text style.
  static final sourceCodePro = GoogleFonts.sourceCodePro();

  /// Black, size 14, medium weight (500) Source Code Pro style.
  static final blackS14W500 = sourceCodePro.copyWith(
    fontWeight: FontWeight.w500,
    fontSize: 14,
  );
}
