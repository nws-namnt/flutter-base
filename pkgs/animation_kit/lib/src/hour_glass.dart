import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Two opposite pie-slice wedges (drawn as filled arcs) that continuously
/// rotate at an ease-out pace, resembling the silhouette of an hourglass
/// spinning in place.
class HourGlass extends StatefulWidget {
  const HourGlass({
    super.key,
    required this.color,
    this.size = 50.0,
    this.duration = const Duration(milliseconds: 1200),
    this.controller,
  });

  /// Color of the two rotating wedges.
  final Color color;

  /// The size of the square box that contains the animation. Defaults to `50.0`.
  final double size;

  /// Duration of one full rotation cycle. Defaults to `1200ms`.
  final Duration duration;

  /// Optional external controller driving the rotation. If not provided, an
  /// internal repeating controller is created and disposed automatically.
  final AnimationController? controller;

  @override
  State<HourGlass> createState() => _HourGlassState();
}

class _HourGlassState extends State<HourGlass> with SingleTickerProviderStateMixin {
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
    _animation = Tween(begin: 0.0, end: 8.0).animate(
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
        transform: Matrix4.identity()..rotateZ((_animation.value) * math.pi),
        alignment: FractionalOffset.center,
        child: CustomPaint(
          painter: _HourGlassPainter(weight: 90, color: widget.color),
          child: SizedBox.fromSize(size: Size.square(widget.size)),
        ),
      ),
    );
  }
}

class _HourGlassPainter extends CustomPainter {
  _HourGlassPainter({required this.weight, required Color color})
      : _paint = Paint()
          ..color = color
          ..strokeWidth = 1.0;

  final Paint _paint;
  final double weight;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromPoints(Offset.zero, Offset(size.width, size.height));
    canvas.drawArc(rect, 0.0, getRadian(weight), true, _paint);
    canvas.drawArc(rect, getRadian(180.0), getRadian(weight), true, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  double getRadian(double angle) => math.pi / 180 * angle;
}
