import 'package:flutter/widgets.dart';

/// A single shape that continuously scales up while fading out (ease-in-out),
/// then snaps back to repeat, resembling a pulsing ripple.
class Pulse extends StatefulWidget {
  const Pulse({
    super.key,
    this.color,
    this.size = 50.0,
    this.itemBuilder,
    this.duration = const Duration(seconds: 1),
    this.controller,
  })  : assert(
          !(itemBuilder is IndexedWidgetBuilder && color is Color) && !(itemBuilder == null && color == null),
          'You should specify either a itemBuilder or a color',
        );

  /// Color of the default circle shape. Ignored if [itemBuilder] is provided.
  final Color? color;

  /// The size of the square box that contains the animation. Defaults to `50.0`.
  final double size;

  /// Optional builder used to render the pulsing shape instead of the
  /// default color-filled circle.
  final IndexedWidgetBuilder? itemBuilder;

  /// Duration of one full pulse cycle. Defaults to `1` second.
  final Duration duration;

  /// Optional external controller driving the animation. If not provided, an
  /// internal repeating controller is created and disposed automatically.
  final AnimationController? controller;

  @override
  State<Pulse> createState() => _PulseState();
}

class _PulseState extends State<Pulse> with SingleTickerProviderStateMixin {
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
    _animation = CurveTween(curve: Curves.easeInOut).animate(_controller);
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
      child: Opacity(
        opacity: 1.0 - _animation.value,
        child: Transform.scale(
          scale: _animation.value,
          child: SizedBox.fromSize(
            size: Size.square(widget.size),
            child: _itemBuilder(0),
          ),
        ),
      ),
    );
  }

  Widget _itemBuilder(int index) => widget.itemBuilder != null
      ? widget.itemBuilder!(context, index)
      : DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color,
          ),
        );
}
