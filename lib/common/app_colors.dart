import 'dart:ui';

import 'package:flutter/material.dart';

/// Semantic color palette used across the app.
///
/// All colors are compile-time constants. Prefer [Theme.of(context).colorScheme]
/// for M3 roles; use these constants only for specific, non-M3 surfaces.
class AppColors {
  // ── Base ──────────────────────────────────────────────────────────────────

  /// Pure white (#FFFFFF).
  static const Color pureWhite = Color(0xFFFFFFFF);

  /// Pure black (#000000).
  static const Color pureBlack = Color(0xFF000000);

  // ── White variants ────────────────────────────────────────────────────────

  /// Light grey tinted white (#F5F5F5).
  static const Color whiteSmoke = Color(0xFFF5F5F5);

  /// Warm off-white with a slight amber cast (#FDF5E6).
  static const Color oldLace = Color(0xFFFDF5E6);

  /// Cool off-white with a faint green tint (#ECEFEC).
  static const Color decoratorsWhite = Color(0xFFECEFEC);

  /// Near-white with the faintest green hue (#FEFFFC).
  static const Color whitewash = Color(0xFFFEFFFC);

  /// Pale grey-green (#E7EAE5).
  static const Color featherWhite = Color(0xFFE7EAE5);

  // ── Black variants ────────────────────────────────────────────────────────

  /// Deep, cool near-black (#0D0E0E).
  static const Color techBlack = Color(0xFF0D0E0E);

  /// Warm near-black with a reddish undertone (#1A0F0F).
  static const Color darkRaisin = Color(0xFF1A0F0F);

  /// Neutral very-dark grey (#212122).
  static const Color inkBlack = Color(0xFF212122);

  /// Dark charcoal grey (#333333).
  static const Color darkCharcoal = Color(0xFF333333);

  /// Rich, warm near-black (#100E09).
  static const Color premiumBlack = Color(0xFF100E09);

  // ── Snackbar colors ────────────────────────────────────────────────────────

  /// Success notification background (#E8F5E9).
  static const cE8F5E9 = Color(0xFFE8F5E9); // success

  /// Error notification background (#FFEBEE).
  static const cFFEBEE = Color(0xFFFFEBEE); // error

  /// Warning notification background (#FFF3E0).
  static const cFFF3E0 = Color(0xFFFFF3E0); // warning

  /// Info notification background (#E1F5FE).
  static const cE1F5FE = Color(0xFFE1F5FE); // info

  /// Success notification icon/text color (#2E7D32).
  static const c2E7D32 = Color(0xFF2E7D32); // success (icon/text) colors

  /// Error notification icon/text color (#C62828).
  static const cC62828 = Color(0xFFC62828); // error (icon/text) colors

  /// Warning notification icon/text color (#EF6C00).
  static const cEF6C00 = Color(0xFFEF6C00); // warning (icon/text) colors

  /// Info notification icon/text color (#0277BD).
  static const c0277BD = Color(0xFF0277BD); // info (icon/text) colors
}
