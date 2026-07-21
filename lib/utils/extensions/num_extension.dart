import 'package:flutter/cupertino.dart';

/// Numeric helpers on [num] (covers both [int] and [double]).
extension NumExtension<T extends num> on T {
  /// Maps this value from `[selfRangeMin, selfRangeMax]` onto
  /// `[normalizedRangeMin, normalizedRangeMax]` (defaults to `0.0 .. 1.0`).
  ///
  /// Works on any [num]; division on [num] always yields a [double], so the
  /// result is always a [double] regardless of whether the receiver is an
  /// [int] or a [double].
  ///
  /// Usage: rescale a value from one range into another — progress bars,
  /// slider-to-real-value mapping, scroll/animation-driven interpolation, etc.
  ///
  /// Example:
  /// ```dart
  /// 2.0.normalized(0, 2.0);            // 1.0
  /// 4.0.normalized(0, 8.0);            // 0.5
  /// 5.0.normalized(4.0, 6.0, 10, 20); // 15.0
  /// 3.normalized(0, 6);               // 0.5  (int receiver -> double result)
  ///
  /// // Map a slider value (0..1) to a temperature (16..30):
  /// final temp = sliderValue.normalized(0, 1, 16, 30);
  ///
  /// // Learning progress for a LinearProgressIndicator:
  /// final progress = lessonsDone.normalized(0, totalLessons);
  /// ```
  double normalized(
    double selfRangeMin,
    double selfRangeMax, [
    double normalizedRangeMin = 0.0,
    double normalizedRangeMax = 1.0,
  ]) {
    return (normalizedRangeMax - normalizedRangeMin) *
            ((this - selfRangeMin) / (selfRangeMax - selfRangeMin)) +
        normalizedRangeMin;
  }
}

extension EdgeInsetsGeometryExtension on double {
  EdgeInsetsGeometry get padAll => EdgeInsets.all(this);

  EdgeInsetsGeometry get padX => EdgeInsets.symmetric(horizontal: this);
  EdgeInsetsGeometry get padY => EdgeInsets.symmetric(vertical: this);

  EdgeInsetsGeometry get padLeft => EdgeInsets.only(left: this);
  EdgeInsetsGeometry get padRight => EdgeInsets.only(right: this);
  EdgeInsetsGeometry get padTop => EdgeInsets.only(top: this);
  EdgeInsetsGeometry get padBottom => EdgeInsets.only(bottom: this);
}