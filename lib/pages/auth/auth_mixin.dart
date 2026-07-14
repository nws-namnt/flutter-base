import 'package:flutter/material.dart';

mixin AuthMixin {
  /// Max height of the collapsible header on auth screens.
  static const double kAuthHeaderMaxExtent = 200.0;

  /// Shared collapsible header for all firebase_ui_auth screens.
  /// Fades out as the user scrolls, exposing the form below.
  Widget authHeaderBuilder(
    BuildContext context,
    BoxConstraints constraints,
    double shrinkOffset,
  ) {
    final opacity =
    (1.0 - shrinkOffset / constraints.maxHeight).clamp(0.0, 1.0);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Opacity(
      opacity: opacity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const FlutterLogo(size: 64, style: FlutterLogoStyle.markOnly),
          const SizedBox(height: 12),
          Text(
            'Flutter Base',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Applies auth-specific button and input overrides on top of the ambient theme.
  ///
  /// Wrap any firebase_ui_auth screen with `Theme(data: authTheme(context), ...)`
  /// to get taller, rounded buttons and filled, rounded text fields that match the
  /// app's [ColorScheme] in both light and dark mode.
  ThemeData authTheme(BuildContext context) {
    final base = Theme.of(context);
    final radius = BorderRadius.circular(12);
    const vPad = EdgeInsets.symmetric(vertical: 14);
    const minSize = Size.fromHeight(52);
    final shape = RoundedRectangleBorder(borderRadius: radius);

    return base.copyWith(
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: vPad,
          minimumSize: minSize,
          shape: shape,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: vPad,
          minimumSize: minSize,
          shape: shape,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: vPad,
          minimumSize: minSize,
          shape: shape,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
      ),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        filled: true,
        fillColor: base.colorScheme.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: base.colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: base.colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: base.colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: base.colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: base.colorScheme.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
