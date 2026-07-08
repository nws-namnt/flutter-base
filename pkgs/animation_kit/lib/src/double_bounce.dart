import 'package:flutter/widgets.dart';

/// Two overlapping circles that alternately scale up and down out of phase,
/// producing a pulsing "double bounce" effect.
///
/// A single ease-in-out animation oscillates between `-1.0` and `1.0`; the
/// two circles derive their scale from `(1.0 - i - value.abs()).abs()` for
/// `i` in `0, 1`, so as one circle grows the other shrinks.
class DoubleBounce extends StatefulWidget {
  const DoubleBounce({
    super.key,
    this.color,
    this.size = 50.0,
    this.itemBuilder,
    this.duration = const Duration(milliseconds: 2000),
    this.controller,
  })  : assert(
          !(itemBuilder is IndexedWidgetBuilder && color is Color) && !(itemBuilder == null && color == null),
          'You should specify either a itemBuilder or a color',
        );

  /// Color of the two circles, rendered at 60% opacity. Ignored when
  /// [itemBuilder] is provided.
  final Color? color;

  /// Side length of the square bounding box that contains each circle.
  final double size;

  /// Builder used to render each circle instead of the default colored
  /// circle.
  final IndexedWidgetBuilder? itemBuilder;

  /// Duration of one full bounce cycle. Defaults to 2000ms. Ignored when
  /// [controller] is provided.
  final Duration duration;

  /// Optional external controller driving the animation. If not provided,
  /// an internal repeating (reverse) controller is created and disposed
  /// automatically.
  final AnimationController? controller;

  @override
  State<DoubleBounce> createState() => _DoubleBounceState();
}

class _DoubleBounceState extends State<DoubleBounce> with SingleTickerProviderStateMixin {
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
      ..repeat(reverse: true);
    _animation = Tween(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
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
        children: List.generate(2, (i) {
          return Transform.scale(
            scale: (1.0 - i - _animation.value.abs()).abs(),
            child: SizedBox.fromSize(
              size: Size.square(widget.size),
              child: _itemBuilder(i),
            ),
          );
        }),
      ),
    );
  }

  Widget _itemBuilder(int index) => widget.itemBuilder != null
      ? widget.itemBuilder!(context, index)
      : DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color!.withValues(alpha: 0.6),
          ),
        );
}
