import 'dart:math';

import 'package:flutter/widgets.dart';

/// A shape that continuously flips around the Y axis (ease-out, multiple
/// half-turns per cycle), simulating a coin-like spin.
class SpinningCircle extends StatefulWidget {
  const SpinningCircle({
    super.key,
    this.color,
    this.shape = BoxShape.circle,
    this.size = 50.0,
    this.itemBuilder,
    this.duration = const Duration(milliseconds: 1200),
    this.controller,
  })  : assert(
          !(itemBuilder is IndexedWidgetBuilder && color is Color) && !(itemBuilder == null && color == null),
          'You should specify either a itemBuilder or a color',
        );

  /// Color of the shape. Ignored when [itemBuilder] is provided.
  final Color? color;

  /// Shape of the default painted widget. Defaults to [BoxShape.circle].
  final BoxShape shape;

  /// The size of the square box that contains the animation. Defaults to `50.0`.
  final double size;

  /// Optional builder used to render a custom widget instead of the default
  /// shape. When provided, [color] should be omitted.
  final IndexedWidgetBuilder? itemBuilder;

  /// Duration of one full spin cycle. Defaults to `1200` milliseconds.
  final Duration duration;

  /// Optional external controller driving the animation. If not provided,
  /// an internal controller is created and repeated automatically.
  final AnimationController? controller;

  @override
  State<SpinningCircle> createState() => _SpinningCircleState();
}

class _SpinningCircleState extends State<SpinningCircle> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = (widget.controller ?? AnimationController(vsync: this, duration: widget.duration))
      ..addListener(() {
        if (mounted) {
          setState(() {});
        }
      })
      ..repeat();
    _animation = Tween(begin: 0.0, end: 7.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
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
    return Center(
      child: Transform(
        transform: Matrix4.identity()..rotateY((0 - _animation.value) * pi),
        alignment: FractionalOffset.center,
        child: SizedBox.fromSize(
          size: Size.square(widget.size),
          child: _itemBuilder(0),
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
