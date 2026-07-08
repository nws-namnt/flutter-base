import 'package:flutter/material.dart';

/// Reusable [Gradient] definitions used across the app.
class AppGradients {
  /// Subtle teal linear gradient at low opacity.
  static const ag1 = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.topLeft,
    colors: [Color.fromRGBO(145, 210, 213, 0.05), Color.fromRGBO(145, 210, 213, 0.05)],
  );
}
