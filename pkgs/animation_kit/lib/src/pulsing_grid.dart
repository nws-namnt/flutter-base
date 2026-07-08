import 'package:flutter/widgets.dart';

import 'delay_tween.dart';

/// A 3x3 grid of shapes that scale in and out with an ease-out curve, using
/// one of three fixed [DelayTween] phase offsets depending on whether a
/// cell is the center, an odd index, or an even index, giving the grid a
/// pulsing checkerboard-like rhythm.
class PulsingGrid extends StatefulWidget {
  const PulsingGrid({
    super.key,
    this.color,
    this.size = 50.0,
    this.itemBuilder,
    this.duration = const Duration(milliseconds: 1500),
    this.boxShape,
    this.controller,
  })  : assert(
          !(itemBuilder is IndexedWidgetBuilder && color is Color) && !(itemBuilder == null && color == null),
          'You should specify either a itemBuilder or a color',
        );

  /// Color of each cell's default shape. Ignored if [itemBuilder] is provided.
  final Color? color;

  /// The size of the square box that contains the entire 3x3 grid. Defaults
  /// to `50.0`.
  final double size;

  /// Optional builder used to render each cell instead of the default
  /// color-filled shape.
  final IndexedWidgetBuilder? itemBuilder;

  /// Duration of one full pulse cycle. Defaults to `1500ms`.
  final Duration duration;

  /// Shape of each cell's default box. Defaults to [BoxShape.circle] if not
  /// provided.
  final BoxShape? boxShape;

  /// Optional external controller driving the animation. If not provided, an
  /// internal repeating controller is created and disposed automatically.
  final AnimationController? controller;

  @override
  State<PulsingGrid> createState() => _PulsingGridState();
}

class _PulsingGridState extends State<PulsingGrid> with SingleTickerProviderStateMixin {
  static const _gridCount = 3;

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
          children: List.generate(_gridCount * _gridCount, (i) {
            final row = (i / _gridCount).floor();
            final column = i % _gridCount;
            final mid = i == (_gridCount * _gridCount - 1) / 2;
            final position = widget.size * .7;
            final delay = mid
                ? .25
                : i.isOdd
                    ? .5
                    : .75;

            return Positioned.fill(
              left: position * (-1 + column),
              top: position * (-1 + row),
              child: Align(
                alignment: Alignment.center,
                child: ScaleTransition(
                  scale: CurvedAnimation(
                    parent: DelayTween(
                      begin: 0.0,
                      end: 1.0,
                      delay: delay,
                    ).animate(_controller),
                    curve: Curves.easeOut,
                  ),
                  child: SizedBox.fromSize(
                    size: Size.square(widget.size / 4),
                    child: _itemBuilder(i),
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
            shape: widget.boxShape ?? BoxShape.circle,
          ),
        );
}
