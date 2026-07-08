import 'dart:math' as math show sin, pi;

import 'package:flutter/animation.dart';

/// A [Tween] that phase-shifts a sine-based easing curve by [delay].
///
/// Used to stagger several items that share a single [AnimationController]:
/// each item gets its own [DelayTween] with a different [delay] value so
/// they reach their peak/trough at different points in the shared cycle.
class DelayTween extends Tween<double> {
  /// Creates a [DelayTween] with the given [begin]/[end] bounds and phase
  /// [delay].
  DelayTween({
    super.begin,
    super.end,
    required this.delay,
  });

  /// The phase offset (as a fraction of the animation cycle, typically in
  /// `0.0`–`1.0`) applied before evaluating the sine easing.
  final double delay;

  @override
  double lerp(double t) {
    return super.lerp((math.sin((t - delay) * 2 * math.pi) + 1) / 2);
  }

  @override
  double evaluate(Animation<double> animation) => lerp(animation.value);
}
