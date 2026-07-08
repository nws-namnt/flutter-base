import 'package:flutter/widgets.dart';

import 'delay_tween.dart';

/// Three circles in a row that scale in and out one after another, each
/// offset by a fixed phase via [DelayTween], producing a left-to-right
/// bouncing wave.
class ThreeBounce extends StatefulWidget {
  const ThreeBounce({
    super.key,
    this.color,
    this.size = 50.0,
    this.itemBuilder,
    this.duration = const Duration(milliseconds: 1400),
    this.controller,
  })  : assert(
          !(itemBuilder is IndexedWidgetBuilder && color is Color) && !(itemBuilder == null && color == null),
          'You should specify either a itemBuilder or a color',
        );

  /// Color of each circle. Ignored if [itemBuilder] is provided. Either this
  /// or [itemBuilder] must be specified.
  final Color? color;

  /// Overall width/height of the row; the row's width is `size * 2` and its
  /// height is `size`. Defaults to `50.0`.
  final double size;

  /// Custom builder used to render each circle instead of the default
  /// [color]-filled circle. Either this or [color] must be specified.
  final IndexedWidgetBuilder? itemBuilder;

  /// Duration of one full bounce cycle across all three circles. Defaults
  /// to `1400` milliseconds.
  final Duration duration;

  /// Optional external controller. If null, an internal one is created and
  /// disposed automatically.
  final AnimationController? controller;

  @override
  State<ThreeBounce> createState() => _ThreeBounceState();
}

class _ThreeBounceState extends State<ThreeBounce> with SingleTickerProviderStateMixin {
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
        size: Size(widget.size * 2, widget.size),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(3, (i) {
            return ScaleTransition(
              scale: DelayTween(
                begin: 0.0,
                end: 1.0,
                delay: i * .2,
              ).animate(_controller),
              child: SizedBox.fromSize(
                size: Size.square(widget.size * 0.5),
                child: _itemBuilder(i),
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
