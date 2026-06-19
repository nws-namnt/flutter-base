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
}
