import 'dart:math';

import 'package:animation_text/src/animated_text_controller.dart';
import 'package:animation_text/src/animation_config.dart';
import 'package:animation_text/src/widgets/per_segment_text.dart';
import 'package:flutter/material.dart';

/// A widget that animates text with a chime bell effect.
class ChimeBellText extends StatelessWidget {
  const ChimeBellText({
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
        final t = config.curve.transform(progress.value.clamp(0.0, 1.0));
        final degrees = 180.0 * (1.0 - t); // Tween(180 -> 0)
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.015) // perspective
            ..rotateX(degrees * pi / 360), // 3D rotation around the X axis
          alignment: Alignment.topCenter,
          child: Opacity(
            opacity: progress.value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
    );
  }
}
