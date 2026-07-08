import 'dart:math';

import 'package:flutter/widgets.dart';

/// An arc segment that both sweeps its length (via [RingCurve], growing
/// then shrinking) and rotates around the circle (via a linear rotation
/// and a shifting start angle), producing a ring-shaped loading spinner.
class Ring extends StatefulWidget {
  const Ring({
    super.key,
    required this.color,
    this.lineWidth = 7.0,
    this.size = 50.0,
    this.duration = const Duration(milliseconds: 1200),
    this.controller,
  });

  /// Color of the arc stroke.
  final Color color;

  /// The size of the square box that contains the animation. Defaults to `50.0`.
  final double size;

  /// Stroke width of the arc. Defaults to `7.0`.
  final double lineWidth;

  /// Duration of one full rotation/sweep cycle. Defaults to `1200` milliseconds.
  final Duration duration;

  /// Optional external controller driving the animation. If not provided,
  /// an internal controller is created and repeated automatically.
  final AnimationController? controller;

  @override
  State<Ring> createState() => _RingState();
}

class _RingState extends State<Ring> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation1;
  late Animation<double> _animation2;
  late Animation<double> _animation3;

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
        curve: const Interval(0.0, 1.0, curve: Curves.linear),
      ),
    );
    _animation2 = Tween(begin: -2 / 3, end: 1 / 2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.linear),
      ),
    );
    _animation3 = Tween(begin: 0.25, end: 5 / 6).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: RingCurve()),
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
        transform: Matrix4.identity()..rotateZ((_animation1.value) * 5 * pi / 6),
        alignment: FractionalOffset.center,
        child: SizedBox.fromSize(
          size: Size.square(widget.size),
          child: CustomPaint(
            foregroundPainter: RingPainter(
              paintWidth: widget.lineWidth,
              trackColor: widget.color,
              progressPercent: _animation3.value,
              startAngle: pi * _animation2.value,
            ),
          ),
        ),
      ),
    );
  }
}

/// Paints the arc segment for [Ring] given a start angle and a sweep
/// percentage of the full circle.
class RingPainter extends CustomPainter {
  RingPainter({
    /// Stroke width used to draw the arc.
    required this.paintWidth,
    /// Fraction (0.0 to 1.0) of the full circle the arc sweeps.
    this.progressPercent,
    /// Angle, in radians, where the arc begins.
    this.startAngle,
    /// Color of the arc stroke.
    required this.trackColor,
  }) : trackPaint = Paint()
          ..color = trackColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = paintWidth
          ..strokeCap = StrokeCap.square;

  /// Stroke width used to draw the arc.
  final double paintWidth;

  /// The [Paint] derived from [trackColor] and [paintWidth] used to stroke the arc.
  final Paint trackPaint;

  /// Color of the arc stroke.
  final Color trackColor;

  /// Fraction (0.0 to 1.0) of the full circle the arc sweeps.
  final double? progressPercent;

  /// Angle, in radians, where the arc begins.
  final double? startAngle;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) - paintWidth) / 2;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle!,
      2 * pi * progressPercent!,
      false,
      trackPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

/// A triangular-wave curve used by [Ring] to grow the arc sweep linearly
/// from `0` to `1` over the first half of the animation, then shrink it
/// linearly back to `0` over the second half.
class RingCurve extends Curve {
  const RingCurve();

  @override
  double transform(double t) => (t <= 0.5) ? 2 * t : 2 * (1 - t);
}
