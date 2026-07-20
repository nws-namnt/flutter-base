import 'package:flutter/material.dart';

import 'app_config.dart' show AppConfig;

/// Reusable [TextStyle] definitions built on the local [AppConfig.kTextTheme]
/// font family (Montserrat).
class AppTextStyle {
  /// Base text style using the app's local font family.
  static const montserrat = TextStyle(fontFamily: AppConfig.kTextTheme);

  /// Black, size 14, medium weight (500) style.
  static final blackS14W500 = montserrat.copyWith(
    fontWeight: FontWeight.w500,
    fontSize: 14,
  );
}
