import 'package:flutter/material.dart';

/// Reusable [BoxShadow] definitions used across the app.
class AppShadows {
  /// Shadow applied above the bottom navigation bar.
  static final bottomNavigationBarShadow = [
    const BoxShadow(
      color: Color(0xFFFF7A00),
      blurRadius: 10,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
  ];
}