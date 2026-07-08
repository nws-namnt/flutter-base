import 'package:flutter/widgets.dart';

/// Two circles chasing each other around a shared square track.
///
/// One circle scales up while the other scales down (via an ease-in-out
/// bounce between `-1.0` and `1.0`) while the whole pair spins a full
/// `360°` at a constant linear rate, giving the illusion of the dots
/// chasing one another in a loop.
class ChasingDots extends StatefulWidget {
  const ChasingDots({
    super.key,
    this.color,
    this.size = 50.0,
    this.itemBuilder,
    this.duration = const Duration(milliseconds: 2000),
  })  : assert(
          !(itemBuilder is IndexedWidgetBuilder && color is Color) && !(itemBuilder == null && color == null),
          'You should specify either a itemBuilder or a color',
        );

  /// Color of the two dots. Ignored when [itemBuilder] is provided.
  final Color? color;

  /// Side length of the square bounding box that contains the animation.
  final double size;

  /// Builder used to render each dot instead of the default colored circle.
  final IndexedWidgetBuilder? itemBuilder;

  /// Duration of one full scale/rotation cycle. Defaults to 2000ms.
  final Duration duration;

  @override
  State<ChasingDots> createState() => _ChasingDotsState();
}

class _ChasingDotsState extends State<ChasingDots> with TickerProviderStateMixin {
  late AnimationController _scaleCtrl;
  late AnimationController _rotateCtrl;
  late Animation<double> _scale;
  late Animation<double> _rotate;

  @override
  void initState() {
    super.initState();

    _scaleCtrl = AnimationController(vsync: this, duration: widget.duration)
      ..addListener(() {
        if (mounted) {
          setState(() {});
        }
      })
      ..repeat(reverse: true);
    _scale = Tween(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeInOut),
    );

    _rotateCtrl = AnimationController(vsync: this, duration: widget.duration)
      ..addListener(() => setState(() {}))
      ..repeat();
    _rotate = Tween(begin: 0.0, end: 360.0).animate(
      CurvedAnimation(parent: _rotateCtrl, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    _rotateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox.fromSize(
        size: Size.square(widget.size),
        child: Transform.rotate(
          angle: _rotate.value * 0.0174533,
          child: Stack(
            children: <Widget>[
              Positioned(top: 0.0, child: _circle(1.0 - _scale.value.abs(), 0)),
              Positioned(bottom: 0.0, child: _circle(_scale.value.abs(), 1)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circle(double scale, int index) {
    return Transform.scale(
      scale: scale,
      child: SizedBox.fromSize(
        size: Size.square(widget.size * 0.6),
        child: widget.itemBuilder != null
            ? widget.itemBuilder!(context, index)
            : DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color,
                ),
              ),
      ),
    );
  }
}
