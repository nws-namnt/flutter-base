import 'package:flutter/widgets.dart';

import 'delay_tween.dart';

/// A ring of small circles arranged evenly around a larger circle, each
/// fading in and out in sequence via a phase-shifted [DelayTween], giving
/// the appearance of a pulse rotating around the ring.
class FadingCircle extends StatefulWidget {
  const FadingCircle({
    super.key,

    /// Color used to paint each dot when [itemBuilder] is not provided.
    this.color,

    /// The width and height of the square box that contains the animation.
    /// Defaults to `50.0`.
    this.size = 50.0,
    this.itemSize,
    this.itemCount,

    /// Builder used to render each dot instead of the default colored
    /// circle. Mutually exclusive with [color].
    this.itemBuilder,

    /// Duration of one full fade cycle around the ring. Defaults to `1200`
    /// milliseconds.
    this.duration = const Duration(milliseconds: 1200),

    /// Optional external [AnimationController]. If provided, this widget
    /// will not create, drive the repeat loop, or dispose its own
    /// controller — the caller owns its lifecycle.
    this.controller,
  })  : assert(
          !(itemBuilder is IndexedWidgetBuilder && color is Color) && !(itemBuilder == null && color == null),
          'You should specify either a itemBuilder or a color',
        );

  /// Color used to paint each dot when [itemBuilder] is not provided.
  final Color? color;

  /// The width and height of the square box that contains the animation.
  /// Defaults to `50.0`.
  final double size;

  /// Size of each individual dot; defaults to `size * 0.15` when null.
  final double? itemSize;

  /// Number of dots evenly spaced around the ring; defaults to `12` when null.
  final int? itemCount;

  /// Builder used to render each dot instead of the default colored
  /// circle. Mutually exclusive with [color].
  final IndexedWidgetBuilder? itemBuilder;

  /// Duration of one full fade cycle around the ring. Defaults to `1200`
  /// milliseconds.
  final Duration duration;

  /// Optional external [AnimationController]. If provided, this widget
  /// will not create, drive the repeat loop, or dispose its own
  /// controller — the caller owns its lifecycle.
  final AnimationController? controller;

  @override
  State<FadingCircle> createState() => _FadingCircleState();
}

class _FadingCircleState extends State<FadingCircle> with SingleTickerProviderStateMixin {
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
    final itemSize = widget.itemSize ?? widget.size * 0.15;
    final itemCount = widget.itemCount ?? 12;

    return Center(
      child: SizedBox.fromSize(
        size: Size.square(widget.size),
        child: Stack(
          children: List.generate(itemCount, (i) {
            final position = widget.size * .5;
            return Positioned.fill(
              left: position,
              top: position,
              child: Transform(
                transform: Matrix4.rotationZ((360 / itemCount) * i * 0.0174533),
                child: Align(
                  alignment: Alignment.center,
                  child: FadeTransition(
                    opacity: DelayTween(
                      begin: 0.0,
                      end: 1.0,
                      delay: i / itemCount,
                    ).animate(_controller),
                    child: SizedBox.fromSize(
                      size: Size.square(itemSize),
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
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
          ),
        );
}
