import 'package:animation_text/src/animated_text_base.dart';
import 'package:animation_text/src/animated_text_controller.dart';
import 'package:animation_text/src/animation_config.dart';
import 'package:animation_text/src/utils/wrap_alignment.dart';
import 'package:animation_text/src/widgets/paragraph_text.dart';
import 'package:flutter/material.dart';

/// Builds the visual for a single text segment from its [progress] animation
/// (0 -> 1), wrapping the pre-built [child] (a [ParagraphText]).
typedef SegmentBuilder = Widget Function(
  BuildContext context,
  int index,
  Animation<double> progress,
  Widget child,
);

/// Shared scaffolding for the simple per-segment text effects.
///
/// Splits the text (via [AnimatedTextBase]), lays segments out in a [Wrap]
/// aligned to [textAlign], and rebuilds each segment on its own animation
/// tick. Each effect only supplies [segmentBuilder] describing how one
/// segment is transformed.
class PerSegmentText extends StatelessWidget {
  const PerSegmentText({
    super.key,
    required this.text,
    required this.config,
    required this.segmentBuilder,
    this.style,
    this.textAlign = TextAlign.start,
    this.onControllerCreated,
  });

  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  final AnimationConfig config;
  final void Function(AnimatedTextController)? onControllerCreated;
  final SegmentBuilder segmentBuilder;

  @override
  Widget build(BuildContext context) {
    return AnimatedTextBase(
      text: text,
      style: style,
      textAlign: textAlign,
      config: config,
      onControllerCreated: onControllerCreated,
      builder: (context, animations, segments) {
        return Wrap(
          alignment: textAlign.wrapAlignment,
          children: List.generate(segments.length, (index) {
            final progress = animations[index];
            final child = ParagraphText(segments[index], style: style);
            return AnimatedBuilder(
              animation: progress,
              builder: (context, _) =>
                  segmentBuilder(context, index, progress, child),
            );
          }),
        );
      },
    );
  }
}
