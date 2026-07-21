import 'package:animation_text/src/animated_text_controller.dart';
import 'package:animation_text/src/animation_config.dart';
import 'package:animation_text/src/enums/slide_animation_type.dart';
import 'package:animation_text/src/utils/offset_tween_by_slide_type.dart';
import 'package:animation_text/src/widgets/per_segment_text.dart';
import 'package:flutter/material.dart';

/// A widget that animates text with a sliding effect.
class SlideText extends StatelessWidget {
  const SlideText({
    super.key,
    required this.text,
    this.style,
    this.textAlign = TextAlign.start,
    required this.config,
    this.slideType = SlideAnimationType.topBottom,
    this.onControllerCreated,
  });

  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  final AnimationConfig config;

  /// The direction from which the text slides in.
  final SlideAnimationType slideType;
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
        final offset =
            offsetTweenBySlideType(slideType, index: index).transform(t);
        return Transform.translate(
          offset: offset,
          child: Opacity(
            opacity: progress.value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
    );
  }
}
