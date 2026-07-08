import 'package:flutter/widgets.dart';

import 'delay_tween.dart';

/// Four overlapping squares, tilted 45 degrees, that fade in and out in a
/// staggered rotation via a phase-shifted [DelayTween], suggesting a cube
/// spinning face by face.
class FadingCube extends StatefulWidget {
  const FadingCube({
    super.key,

    /// Color used to paint each square when [itemBuilder] is not provided.
    this.color,

    /// The width and height of the square box that contains the animation.
    /// Defaults to `50.0`.
    this.size = 50.0,

    /// Builder used to render each square instead of the default colored
    /// box. Mutually exclusive with [color].
    this.itemBuilder,

    /// Duration of one full staggered fade cycle across the four squares.
    /// Defaults to `2400` milliseconds.
    this.duration = const Duration(milliseconds: 2400),

    /// Optional external [AnimationController]. If provided, this widget
    /// will not create, drive the repeat loop, or dispose its own
    /// controller — the caller owns its lifecycle.
    this.controller,
  })  : assert(
          !(itemBuilder is IndexedWidgetBuilder && color is Color) && !(itemBuilder == null && color == null),
          'You should specify either a itemBuilder or a color',
        );

  /// Color used to paint each square when [itemBuilder] is not provided.
  final Color? color;

  /// The width and height of the square box that contains the animation.
  /// Defaults to `50.0`.
  final double size;

  /// Builder used to render each square instead of the default colored
  /// box. Mutually exclusive with [color].
  final IndexedWidgetBuilder? itemBuilder;

  /// Duration of one full staggered fade cycle across the four squares.
  /// Defaults to `2400` milliseconds.
  final Duration duration;

  /// Optional external [AnimationController]. If provided, this widget
  /// will not create, drive the repeat loop, or dispose its own
  /// controller — the caller owns its lifecycle.
  final AnimationController? controller;

  @override
  State<FadingCube> createState() => _FadingCubeState();
}

class _FadingCubeState extends State<FadingCube> with SingleTickerProviderStateMixin {
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
        child: Center(
          child: Transform.rotate(
            angle: -45.0 * 0.0174533,
            child: Stack(
              children: List.generate(4, (i) {
                final size = widget.size * 0.5, position = widget.size * .5;
                return Positioned.fill(
                  top: position,
                  left: position,
                  child: Transform.scale(
                    scale: 1.1,
                    origin: Offset(-size * .5, -size * .5),
                    child: Transform(
                      transform: Matrix4.rotationZ(90.0 * i * 0.0174533),
                      child: Align(
                        alignment: Alignment.center,
                        child: FadeTransition(
                          opacity: DelayTween(
                            begin: 0.0,
                            end: 1.0,
                            delay: 0.3 * i,
                          ).animate(_controller),
                          child: SizedBox.fromSize(
                            size: Size.square(size),
                            child: _itemBuilder(i),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _itemBuilder(int index) => widget.itemBuilder != null
      ? widget.itemBuilder!(context, index)
      : DecoratedBox(decoration: BoxDecoration(color: widget.color));
}
