import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// A shape that morphs between a square and a circle by animating its
/// corner radius while simultaneously shrinking/growing and rotating a
/// half turn, using a single ease-in-out-cubic animation played forward
/// and reverse.
class SquareCircle extends StatefulWidget {
  const SquareCircle({
    super.key,
    this.color,
    this.size = 50.0,
    this.itemBuilder,
    this.duration = const Duration(milliseconds: 500),
    this.controller,
  })  : assert(
          !(itemBuilder is IndexedWidgetBuilder && color is Color) && !(itemBuilder == null && color == null),
          'You should specify either a itemBuilder or a color',
        );

  /// Color of the shape. Ignored if [itemBuilder] is provided. Either this
  /// or [itemBuilder] must be specified.
  final Color? color;

  /// Side length of the square bounding box the shape animates within.
  /// Defaults to `50.0`.
  final double size;

  /// Custom builder used to render the shape instead of the default
  /// [color]-filled box. Either this or [color] must be specified.
  final IndexedWidgetBuilder? itemBuilder;

  /// Duration of one forward (or reverse) morph between square and circle.
  /// Defaults to `500` milliseconds.
  final Duration duration;

  /// Optional external controller. If null, an internal one is created and
  /// disposed automatically.
  final AnimationController? controller;

  @override
  State<SquareCircle> createState() => _SquareCircleState();
}

class _SquareCircleState extends State<SquareCircle> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animationCurve;
  late Animation<double> _animationSize;

  @override
  void initState() {
    super.initState();

    _controller = (widget.controller ?? AnimationController(vsync: this, duration: widget.duration))
      ..addListener(() {
        if (mounted) {
          setState(() {});
        }
      })
      ..repeat(reverse: true);
    final animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
    _animationCurve = Tween(begin: 1.0, end: 0.0).animate(animation);
    _animationSize = Tween(begin: 0.5, end: 1.0).animate(animation);
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
    final sizeValue = widget.size * _animationSize.value;
    return Center(
      child: Transform(
        transform: Matrix4.identity()..rotateZ(_animationCurve.value * math.pi),
        alignment: FractionalOffset.center,
        child: SizedBox.fromSize(
          size: Size.square(sizeValue),
          child: _itemBuilder(0, 0.5 * sizeValue * _animationCurve.value),
        ),
      ),
    );
  }

  Widget _itemBuilder(int index, double curveValue) {
    return widget.itemBuilder != null
        ? widget.itemBuilder!(context, index)
        : DecoratedBox(
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.all(Radius.circular(curveValue)),
            ),
          );
  }
}
