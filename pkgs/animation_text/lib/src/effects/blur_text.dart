import 'dart:ui';

import 'package:animation_text/src/animated_text_controller.dart';
import 'package:animation_text/src/animation_config.dart';
import 'package:animation_text/src/widgets/per_segment_text.dart';
import 'package:flutter/material.dart';

/// A widget that animates text with a blur effect.
class BlurText extends StatelessWidget {
  const BlurText({
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
        // Tween(begin: 10, end: 0) driven by config.curve.
        final t = config.curve.transform(progress.value.clamp(0.0, 1.0));
        final sigma = (10.0 * (1.0 - t)).clamp(0.0, 10.0);
        return ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
          child: Opacity(
            opacity: progress.value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
    );
  }
}
