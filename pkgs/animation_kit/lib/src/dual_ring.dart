import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Two opposite arc segments (a "dual ring") that continuously rotate a
/// full `360°` at a constant linear rate, forming a spinning ring loader.
class DualRing extends StatefulWidget {
  const DualRing({
    super.key,
    required this.color,

    /// Stroke width of the two arc segments. Defaults to `7.0`.
    this.lineWidth = 7.0,

    /// The width and height of the square box that contains the animation.
    /// Defaults to `50.0`.
    this.size = 50.0,

    /// Duration of one full `360°` rotation. Defaults to `1200` milliseconds.
    this.duration = const Duration(milliseconds: 1200),

    /// Optional external [AnimationController]. If provided, this widget
    /// will not create, drive the repeat loop, or dispose its own
    /// controller — the caller owns its lifecycle.
    this.controller,
  });

  /// Color of the two arc segments.
  final Color color;

  /// Stroke width of the two arc segments. Defaults to `7.0`.
  final double lineWidth;

  /// The width and height of the square box that contains the animation.
  /// Defaults to `50.0`.
  final double size;

  /// Duration of one full `360°` rotation. Defaults to `1200` milliseconds.
  final Duration duration;

  /// Optional external [AnimationController]. If provided, this widget
  /// will not create, drive the repeat loop, or dispose its own
  /// controller — the caller owns its lifecycle.
  final AnimationController? controller;

  @override
  State<DualRing> createState() => _DualRingState();
}

class _DualRingState extends State<DualRing> with SingleTickerProviderStateMixin {
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
    _animation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.linear),
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
        transform: Matrix4.identity()..rotateZ((_animation.value) * math.pi * 2),
        alignment: FractionalOffset.center,
        child: CustomPaint(
          painter: _DualRingPainter(
            angle: 90,
            paintWidth: widget.lineWidth,
            color: widget.color,
          ),
          child: SizedBox.fromSize(size: Size.square(widget.size)),
        ),
      ),
    );
  }
}

class _DualRingPainter extends CustomPainter {
  _DualRingPainter({
    required this.angle,
    required double paintWidth,
    required Color color,
  }) : ringPaint = Paint()
          ..color = color
          ..strokeWidth = paintWidth
          ..style = PaintingStyle.stroke;

  final Paint ringPaint;
  final double angle;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromPoints(Offset.zero, Offset(size.width, size.height));
    canvas.drawArc(rect, 0.0, getRadian(angle), false, ringPaint);
    canvas.drawArc(rect, getRadian(180.0), getRadian(angle), false, ringPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  double getRadian(double angle) => math.pi / 180 * angle;
}
