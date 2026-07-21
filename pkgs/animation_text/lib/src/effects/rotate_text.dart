import 'dart:math';

import 'package:animation_text/src/animated_text_controller.dart';
import 'package:animation_text/src/animation_config.dart';
import 'package:animation_text/src/enums/rotate_animation_type.dart';
import 'package:animation_text/src/utils/double_tween_by_rotate_type.dart';
import 'package:animation_text/src/widgets/per_segment_text.dart';
import 'package:flutter/material.dart';

/// A widget that animates text with a rotation effect.
class RotateText extends StatelessWidget {
  const RotateText({
    super.key,
    required this.text,
    this.style,
    this.textAlign = TextAlign.start,
    required this.config,
    this.direction = RotateAnimationType.clockwise,
    this.onControllerCreated,
  });

  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  final AnimationConfig config;

  /// The type of rotation animation to apply.
  final RotateAnimationType direction;
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
        final degrees = doubleTweenByRotateType(direction).transform(t);
        return Transform(
          transform: Matrix4.identity()..rotateZ(degrees * pi / 180),
          alignment: Alignment.center,
          child: Opacity(
            opacity: progress.value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
    );
  }
}
