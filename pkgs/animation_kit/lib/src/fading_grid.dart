import 'package:flutter/widgets.dart';

import 'delay_tween.dart';

/// A 3x3 grid of shapes (skipping the center cell) that fade between two
/// opacity levels with per-row phase offsets (via [DelayTween]), producing
/// a rippling fade effect across the grid.
class FadingGrid extends StatefulWidget {
  const FadingGrid({
    super.key,

    /// Color used to paint each grid cell when [itemBuilder] is not
    /// provided.
    this.color,

    /// Shape of each grid cell. Defaults to [BoxShape.circle].
    this.shape = BoxShape.circle,

    /// The width and height of the square box that contains the animation.
    /// Defaults to `50.0`.
    this.size = 50.0,

    /// Builder used to render each grid cell instead of the default
    /// colored shape. Mutually exclusive with [color].
    this.itemBuilder,

    /// Duration of one full rippling fade cycle across the grid. Defaults
    /// to `1200` milliseconds.
    this.duration = const Duration(milliseconds: 1200),

    /// Optional external [AnimationController]. If provided, this widget
    /// will not create, drive the repeat loop, or dispose its own
    /// controller — the caller owns its lifecycle.
    this.controller,
  })  : assert(
          !(itemBuilder is IndexedWidgetBuilder && color is Color) && !(itemBuilder == null && color == null),
          'You should specify either a itemBuilder or a color',
        );

  /// Color used to paint each grid cell when [itemBuilder] is not
  /// provided.
  final Color? color;

  /// Shape of each grid cell. Defaults to [BoxShape.circle].
  final BoxShape shape;

  /// The width and height of the square box that contains the animation.
  /// Defaults to `50.0`.
  final double size;

  /// Builder used to render each grid cell instead of the default
  /// colored shape. Mutually exclusive with [color].
  final IndexedWidgetBuilder? itemBuilder;

  /// Duration of one full rippling fade cycle across the grid. Defaults
  /// to `1200` milliseconds.
  final Duration duration;

  /// Optional external [AnimationController]. If provided, this widget
  /// will not create, drive the repeat loop, or dispose its own
  /// controller — the caller owns its lifecycle.
  final AnimationController? controller;

  @override
  State<FadingGrid> createState() => _FadingGridState();
}

class _FadingGridState extends State<FadingGrid> with SingleTickerProviderStateMixin {
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
    return SizedBox.fromSize(
      size: Size.square(widget.size),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _circle(0, 1),
              SizedBox(width: widget.size / 8),
              _circle(1, 1),
              SizedBox(width: widget.size / 8),
              _circle(2, 2),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: widget.size / 8, width: widget.size),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _circle(3, 4),
              SizedBox(width: widget.size / 8),
              _circle(4, 1),
              SizedBox(width: widget.size / 8),
              _circle(5, 2),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: widget.size / 8, width: widget.size),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _circle(6, 4),
              SizedBox(width: widget.size / 8),
              _circle(7, 3),
              SizedBox(width: widget.size / 8),
              _circle(8, 3),
            ],
          ),
        ],
      ),
    );
  }

  Widget _circle(int index, int i) {
    return FadeTransition(
      opacity: DelayTween(
        begin: 0.4,
        end: 0.9,
        delay: 0.3 * (i - 1),
      ).animate(_controller),
      child: SizedBox.fromSize(
        size: Size.square(widget.size / 4),
        child: _itemBuilder(index),
      ),
    );
  }

  Widget _itemBuilder(int index) => widget.itemBuilder != null
      ? widget.itemBuilder!(context, index)
      : DecoratedBox(
          decoration: BoxDecoration(color: widget.color, shape: widget.shape),
        );
}
