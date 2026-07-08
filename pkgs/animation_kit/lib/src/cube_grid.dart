import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// A 3x3 grid of squares that fade in and out in a diagonal wave pattern.
///
/// Five overlapping ease-in [Interval]s (reused across the nine cells) drive
/// each square's scale from `1.0` to `0.0` and back, staggered so the
/// shrink/grow effect appears to sweep diagonally across the grid. The
/// whole grid is also flipped `180°` depending on the controller's
/// forward/reverse status.
class CubeGrid extends StatefulWidget {
  const CubeGrid({
    super.key,
    this.color,
    this.size = 50.0,
    this.itemBuilder,
    this.duration = const Duration(milliseconds: 1200),
    this.controller,
  })  : assert(
          !(itemBuilder is IndexedWidgetBuilder && color is Color) && !(itemBuilder == null && color == null),
          'You should specify either a itemBuilder or a color',
        );

  /// Color of the squares. Ignored when [itemBuilder] is provided.
  final Color? color;

  /// Side length of the square bounding box that contains the 3x3 grid.
  final double size;

  /// Builder used to render each square instead of the default colored box.
  final IndexedWidgetBuilder? itemBuilder;

  /// Duration of one full fade cycle. Defaults to 1200ms. Ignored when
  /// [controller] is provided.
  final Duration duration;

  /// Optional external controller driving the animation. If not provided,
  /// an internal repeating (reverse) controller is created and disposed
  /// automatically.
  final AnimationController? controller;

  @override
  State<CubeGrid> createState() => _CubeGridState();
}

class _CubeGridState extends State<CubeGrid> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim1;
  late Animation<double> _anim2;
  late Animation<double> _anim3;
  late Animation<double> _anim4;
  late Animation<double> _anim5;

  @override
  void initState() {
    super.initState();

    _controller = (widget.controller ?? AnimationController(vsync: this, duration: widget.duration))
      ..repeat(reverse: true);
    _anim1 = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.6, curve: Curves.easeIn),
      ),
    );
    _anim2 = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.7, curve: Curves.easeIn),
      ),
    );
    _anim3 = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.8, curve: Curves.easeIn),
      ),
    );
    _anim4 = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.9, curve: Curves.easeIn),
      ),
    );
    _anim5 = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        final double angle = _controller.status == AnimationStatus.forward ? 0 : math.pi;
        // Just rotate it 180 degrees to display it as showcased
        return Transform.rotate(
          angle: angle,
          child: child,
        );
      },
      child: SizedBox.fromSize(
        size: Size.square(widget.size),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _square(_anim3, 0),
                _square(_anim4, 1),
                _square(_anim5, 2),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _square(_anim2, 3),
                _square(_anim3, 4),
                _square(_anim4, 5),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _square(_anim1, 6),
                _square(_anim2, 7),
                _square(_anim3, 8),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _square(Animation<double> animation, int index) {
    return ScaleTransition(
      scale: animation,
      child: SizedBox.fromSize(
        size: Size.square(widget.size / 3),
        child: _itemBuilder(index),
      ),
    );
  }

  Widget _itemBuilder(int index) => widget.itemBuilder != null
      ? widget.itemBuilder!(context, index)
      : DecoratedBox(decoration: BoxDecoration(color: widget.color));
}
