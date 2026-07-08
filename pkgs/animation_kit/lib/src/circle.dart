import 'package:flutter/widgets.dart';

import 'delay_tween.dart';

/// A ring of 12 small dots arranged around a circle, each fading/scaling
/// in and out in sequence via a phase-shifted [DelayTween], producing a
/// rotating pulse effect around the circumference.
class Circle extends StatefulWidget {
  const Circle({
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

  /// Color of the dots. Ignored when [itemBuilder] is provided.
  final Color? color;

  /// Diameter of the circle the dots are arranged around.
  final double size;

  /// Builder used to render each dot instead of the default colored circle.
  final IndexedWidgetBuilder? itemBuilder;

  /// Duration of one full rotation cycle. Defaults to 1200ms. Ignored when
  /// [controller] is provided.
  final Duration duration;

  /// Optional external controller driving the animation. If not provided,
  /// an internal repeating controller is created and disposed automatically.
  final AnimationController? controller;

  @override
  State<Circle> createState() => _CircleState();
}

class _CircleState extends State<Circle> with SingleTickerProviderStateMixin {
  static const _itemCount = 12;

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
          children: List.generate(_itemCount, (index) {
            final position = widget.size * .5;
            return Positioned.fill(
              left: position,
              top: position,
              child: Transform(
                transform: Matrix4.rotationZ(30.0 * index * 0.0174533),
                child: Align(
                  alignment: Alignment.center,
                  child: ScaleTransition(
                    scale: DelayTween(
                      begin: 0.0,
                      end: 1.0,
                      delay: index / _itemCount,
                    ).animate(_controller),
                    child: SizedBox.fromSize(
                      size: Size.square(widget.size * 0.15),
                      child: _itemBuilder(index),
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
