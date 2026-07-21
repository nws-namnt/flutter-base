import 'package:animation_text/src/animated_text_controller.dart';
import 'package:animation_text/src/animation_config.dart';
import 'package:animation_text/src/utils/spring_curve.dart';
import 'package:animation_text/src/widgets/per_segment_text.dart';
import 'package:flutter/material.dart';

/// A widget that animates text with a spring effect.
class SpringText extends StatelessWidget {
  const SpringText({
    super.key,
    required this.text,
    this.style,
    this.textAlign = TextAlign.start,
    required this.config,
    this.onControllerCreated,
  });

  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  final AnimationConfig config;
  final void Function(AnimatedTextController)? onControllerCreated;

  @override
  Widget build(BuildContext context) {
    return PerSegmentText(
      text: text,
      style: style,
      textAlign: textAlign,
      config: config,
      onControllerCreated: onControllerCreated,
      segmentBuilder: (context, index, progress, child) {
        final p = progress.value.clamp(0.0, 1.0);
        // dampingRatio = damping / (2 * sqrt(mass * stiffness)) ≈ 0.28 -> ~37%
        // overshoot. Hard-coded so SpringText always feels like a spring
        // regardless of what curve the caller puts in config.curve.
        const spring = SpringCurve(stiffness: 200.0, damping: 12.0, duration: 1.2);
        final y = 50.0 * (1.0 - spring.transform(p)); // Tween(50 -> 0)
        // Fade in during the first third so the bounce is fully visible.
        final opacity =
            const Interval(0.0, 0.35, curve: Curves.easeOut).transform(p);
        return Transform.translate(
          offset: Offset(0.0, y),
          child: Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
    );
  }
}
