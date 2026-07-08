import 'package:flutter/widgets.dart';

import 'delay_tween.dart';

/// Four shapes positioned around a circle that fade in and out with fixed,
/// hand-tuned phase offsets (via [DelayTween]), producing a staggered pulse
/// that cycles through the four positions.
class FadingFour extends StatefulWidget {
  const FadingFour({
    super.key,

    /// Color used to paint each shape when [itemBuilder] is not provided.
    this.color,

    /// Shape of each of the four items. Defaults to [BoxShape.circle].
    this.shape = BoxShape.circle,

    /// The width and height of the square box that contains the animation.
    /// Defaults to `50.0`.
    this.size = 50.0,

    /// Builder used to render each shape instead of the default colored
    /// shape. Mutually exclusive with [color].
    this.itemBuilder,

    /// Duration of one full staggered pulse cycle across the four
    /// positions. Defaults to `1200` milliseconds.
    this.duration = const Duration(milliseconds: 1200),

    /// Optional external [AnimationController]. If provided, this widget
    /// will not create, drive the repeat loop, or dispose its own
    /// controller — the caller owns its lifecycle.
    this.controller,
  })  : assert(
          !(itemBuilder is IndexedWidgetBuilder && color is Color) && !(itemBuilder == null && color == null),
          'You should specify either a itemBuilder or a color',
        );

  /// Color used to paint each shape when [itemBuilder] is not provided.
  final Color? color;

  /// Shape of each of the four items. Defaults to [BoxShape.circle].
  final BoxShape shape;

  /// The width and height of the square box that contains the animation.
  /// Defaults to `50.0`.
  final double size;

  /// Builder used to render each shape instead of the default colored
  /// shape. Mutually exclusive with [color].
  final IndexedWidgetBuilder? itemBuilder;

  /// Duration of one full staggered pulse cycle across the four
  /// positions. Defaults to `1200` milliseconds.
  final Duration duration;

  /// Optional external [AnimationController]. If provided, this widget
  /// will not create, drive the repeat loop, or dispose its own
  /// controller — the caller owns its lifecycle.
  final AnimationController? controller;

  @override
  State<FadingFour> createState() => _FadingFourState();
}

class _FadingFourState extends State<FadingFour> with SingleTickerProviderStateMixin {
  static const List<double> _delays = [.0, -0.9, -0.6, -0.3];
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = (widget.controller ?? AnimationController(vsync: this, duration: widget.duration))..repeat();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox.fromSize(
        size: Size.square(widget.size),
        child: Stack(
          children: List.generate(4, (i) {
            final position = widget.size * .5;
            return Positioned.fill(
              left: position,
              top: position,
              child: Transform(
                transform: Matrix4.rotationZ(30.0 * (i * 3) * 0.0174533),
                child: Align(
                  alignment: Alignment.center,
                  child: FadeTransition(
                    opacity: DelayTween(
                      begin: 0.0,
                      end: 1.0,
                      delay: _delays[i],
                    ).animate(_controller),
                    child: SizedBox.fromSize(
                      size: Size.square(widget.size * 0.25),
                      child: _itemBuilder(i),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _itemBuilder(int index) => widget.itemBuilder != null
      ? widget.itemBuilder!(context, index)
      : DecoratedBox(
          decoration: BoxDecoration(color: widget.color, shape: widget.shape),
        );
}
