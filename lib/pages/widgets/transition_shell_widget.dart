import 'package:flutter/material.dart';

/// Transition types for bottom navigation shell tab switches.
///
/// Parallel to [PageTransitionType] but designed for [AnimatedBranchContainer]:
/// receives pre-built [opacity] and [position] animations managed as
/// long-lived fields (no CurvedAnimation leak).
///
/// Directional types (slide, slideFade) use the [position] animation whose
/// begin offset is mutated by [AnimatedBranchContainer.didUpdateWidget]
/// based on the direction of the tab switch.
enum ShellTransitionType {
  /// Simple cross-fade.
  fade,

  /// Directional slide — begin offset set by caller based on index delta.
  slide,

  /// Directional slide combined with fade-in.
  slideFade,

  /// Subtle scale-up (0.95 → 1.0) combined with fade-in. iOS-style.
  scaleFade,
}

/// Extension that converts a [ShellTransitionType] into a concrete widget.
extension ShellTransitionExt on ShellTransitionType {
  /// Wraps [child] with the appropriate transition widget.
  ///
  /// [opacity] — a 0→1 [Animation<double>] (CurvedAnimation stored as field).
  /// [position] — a begin→Offset.zero [Animation<Offset>] (Tween stored as field).
  Widget transition({
    required Widget child,
    required Animation<double> opacity,
    required Animation<Offset> position,
  }) {
    switch (this) {
      case ShellTransitionType.fade:
        return FadeTransition(opacity: opacity, child: child);

      case ShellTransitionType.slide:
        return SlideTransition(position: position, child: child);

      case ShellTransitionType.slideFade:
        return FadeTransition(
          opacity: opacity,
          child: SlideTransition(position: position, child: child),
        );

      case ShellTransitionType.scaleFade:
        // Tween.animate() is safe to create inline — it wraps without adding
        // any listener to the parent animation.
        return FadeTransition(
          opacity: opacity,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(opacity),
            child: child,
          ),
        );
    }
  }
}
