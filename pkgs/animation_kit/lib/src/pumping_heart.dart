import 'dart:math' as math show pow;

import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';

/// A heart icon that scales from `1.0` to `1.25` following a custom
/// [PumpCurve] with two beats per cycle, mimicking a heartbeat pump.
class PumpingHeart extends StatefulWidget {
  const PumpingHeart({
    super.key,
    this.color,
    this.size = 50.0,
    this.itemBuilder,
    this.duration = const Duration(milliseconds: 2400),
    this.controller,
  })  : assert(
          !(itemBuilder is IndexedWidgetBuilder && color is Color) && !(itemBuilder == null && color == null),
          'You should specify either a itemBuilder or a color',
        );

  /// Color of the heart icon. Ignored when [itemBuilder] is provided.
  final Color? color;

  /// The size of the square box that contains the animation. Defaults to `50.0`.
  final double size;

  /// Optional builder used to render a custom widget instead of the default
  /// heart icon. When provided, [color] should be omitted.
  final IndexedWidgetBuilder? itemBuilder;

  /// Duration of one full pump cycle (two beats plus a rest period).
  /// Defaults to `2400` milliseconds.
  final Duration duration;

  /// Optional external controller driving the animation. If not provided,
  /// an internal controller is created and repeated automatically.
  final AnimationController? controller;

  @override
  State<PumpingHeart> createState() => _PumpingHeartState();
}

class _PumpingHeartState extends State<PumpingHeart> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = (widget.controller ?? AnimationController(vsync: this, duration: widget.duration))..repeat();
    _animation = Tween(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: PumpCurve()),
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
    return ScaleTransition(scale: _animation, child: _itemBuilder(0));
  }

  Widget _itemBuilder(int index) => widget.itemBuilder != null
      ? widget.itemBuilder!(context, index)
      : Icon(Icons.favorite, color: widget.color, size: widget.size);
}

/// A piecewise easing curve for [PumpingHeart] that produces two
/// quick rise/fall "beats" (a strong beat then a softer one) within a
/// single animation cycle, followed by a brief rest period.
class PumpCurve extends Curve {
  const PumpCurve();

  static const magicNumber = 4.54545454;

  @override
  double transform(double t) {
    if (t >= 0.0 && t < 0.22) {
      return math.pow(t, 1.0) * magicNumber;
    } else if (t >= 0.22 && t < 0.44) {
      return 1.0 - (math.pow(t - 0.22, 1.0) * magicNumber);
    } else if (t >= 0.44 && t < 0.5) {
      return 0.0;
    } else if (t >= 0.5 && t < 0.72) {
      return math.pow(t - 0.5, 1.0) * (magicNumber / 2);
    } else if (t >= 0.72 && t < 0.94) {
      return 0.5 - (math.pow(t - 0.72, 1.0) * (magicNumber / 2));
    }
    return 0.0;
  }
}
