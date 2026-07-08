import 'package:flutter/widgets.dart';

/// Two expanding, fading concentric ring outlines started half a cycle
/// apart (via overlapping linear [Interval]s), producing a continuous
/// ripple/sonar effect.
class Ripple extends StatefulWidget {
  const Ripple({
    super.key,
    this.color,
    this.size = 50.0,
    this.borderWidth = 6.0,
    this.itemBuilder,
    this.duration = const Duration(milliseconds: 1800),
    this.controller,
  })  : assert(
          !(itemBuilder is IndexedWidgetBuilder && color is Color) && !(itemBuilder == null && color == null),
          'You should specify either a itemBuilder or a color',
        );

  /// Color of the ring outlines. Ignored when [itemBuilder] is provided.
  final Color? color;

  /// The size of the square box that contains the animation. Defaults to `50.0`.
  final double size;

  /// Stroke width of each ring outline; defaults to `6.0`.
  final double borderWidth;

  /// Optional builder used to render a custom widget for each of the two
  /// ripple layers instead of the default ring outline. When provided,
  /// [color] should be omitted.
  final IndexedWidgetBuilder? itemBuilder;

  /// Duration of one full ripple cycle. Defaults to `1800` milliseconds.
  final Duration duration;

  /// Optional external controller driving the animation. If not provided,
  /// an internal controller is created and repeated automatically.
  final AnimationController? controller;

  @override
  State<Ripple> createState() => _RippleState();
}

class _RippleState extends State<Ripple> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation1;
  late Animation<double> _animation2;

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
    _animation1 = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.75, curve: Curves.linear),
      ),
    );
    _animation2 = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 1.0, curve: Curves.linear),
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
      child: Stack(
        children: <Widget>[
          Opacity(
            opacity: 1.0 - _animation1.value,
            child: Transform.scale(
              scale: _animation1.value,
              child: _itemBuilder(0),
            ),
          ),
          Opacity(
            opacity: 1.0 - _animation2.value,
            child: Transform.scale(
              scale: _animation2.value,
              child: _itemBuilder(1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemBuilder(int index) {
    return SizedBox.fromSize(
      size: Size.square(widget.size),
      child: widget.itemBuilder != null
          ? widget.itemBuilder!(context, index)
          : DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.color!,
                  width: widget.borderWidth,
                ),
              ),
            ),
    );
  }
}
