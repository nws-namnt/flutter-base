import 'package:flutter/widgets.dart';

/// Two shapes that travel around a square path (translating and rotating
/// a full `360°`) while scaling up and down at each corner, giving the
/// impression of cubes wandering around a track.
class WanderingCubes extends StatefulWidget {
  const WanderingCubes({
    super.key,
    this.color,
    this.shape = BoxShape.rectangle,
    this.size = 50.0,
    this.itemBuilder,
    this.duration = const Duration(milliseconds: 1800),
  })  : assert(
          !(itemBuilder is IndexedWidgetBuilder && color is Color) && !(itemBuilder == null && color == null),
          'You should specify either a itemBuilder or a color',
        ),
        offset = size * 0.75;

  /// Color of each cube. Ignored if [itemBuilder] is provided. Either this
  /// or [itemBuilder] must be specified.
  final Color? color;

  /// Shape of each cube. Defaults to [BoxShape.rectangle].
  final BoxShape shape;

  /// Distance each cube travels along the path; derived from [size]
  /// (`size * 0.75`).
  final double offset;

  /// Side length of the square area the animation occupies; each cube is
  /// `size * 0.25`. Defaults to `50.0`.
  final double size;

  /// Custom builder used to render each cube instead of the default
  /// [color]-filled shape. Either this or [color] must be specified.
  final IndexedWidgetBuilder? itemBuilder;

  /// Duration of one full loop around the square path. Defaults to `1800`
  /// milliseconds.
  final Duration duration;

  @override
  State<WanderingCubes> createState() => _WanderingCubesState();
}

class _WanderingCubesState extends State<WanderingCubes> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale1;
  late Animation<double> _scale2;
  late Animation<double> _scale3;
  late Animation<double> _scale4;
  late Animation<double> _rotate;
  late Animation<double> _translate1;
  late Animation<double> _translate2;
  late Animation<double> _translate3;
  late Animation<double> _translate4;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..addListener(() {
        if (mounted) {
          setState(() {});
        }
      })
      ..repeat();

    final animation1 = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.25, curve: Curves.easeInOut),
    );
    _translate1 = Tween(begin: 0.0, end: widget.offset).animate(animation1);
    _scale1 = Tween(begin: 1.0, end: 0.5).animate(animation1);

    final animation2 = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.25, 0.5, curve: Curves.easeInOut),
    );
    _translate2 = Tween(begin: 0.0, end: widget.offset).animate(animation2);
    _scale2 = Tween(begin: 1.0, end: 2.0).animate(animation2);

    final animation3 = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 0.75, curve: Curves.easeInOut),
    );
    _translate3 = Tween(begin: 0.0, end: -widget.offset).animate(animation3);
    _scale3 = Tween(begin: 1.0, end: 0.5).animate(animation3);

    final animation4 = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.75, 1.0, curve: Curves.easeInOut),
    );
    _translate4 = Tween(begin: 0.0, end: -widget.offset).animate(animation4);
    _scale4 = Tween(begin: 1.0, end: 2.0).animate(animation4);

    _rotate = Tween(begin: 0.0, end: 360.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox.fromSize(
        size: Size.square(widget.size),
        child: Stack(
          children: <Widget>[
            _cube(0),
            _cube(1, true),
          ],
        ),
      ),
    );
  }

  Widget _cube(int index, [bool offset = false]) {
    Matrix4 tTranslate;
    if (offset == true) {
      tTranslate = Matrix4.identity()
        ..translateByDouble(_translate3.value, 0.0, 0.0, 1.0)
        ..translateByDouble(0.0, _translate2.value, 0.0, 1.0)
        ..translateByDouble(0.0, _translate4.value, 0.0, 1.0)
        ..translateByDouble(_translate1.value, 0.0, 0.0, 1.0);
    } else {
      tTranslate = Matrix4.identity()
        ..translateByDouble(0.0, _translate3.value, 0.0, 1.0)
        ..translateByDouble(-_translate2.value, 0.0, 0.0, 1.0)
        ..translateByDouble(-_translate4.value, 0.0, 0.0, 1.0)
        ..translateByDouble(0.0, _translate1.value, 0.0, 1.0);
    }

    return Positioned(
      top: 0.0,
      left: offset == true ? 0.0 : widget.offset,
      child: Transform(
        transform: tTranslate,
        child: Transform.rotate(
          angle: _rotate.value * 0.0174533,
          child: Transform(
            transform: Matrix4.identity()
              ..scaleByDouble(_scale2.value, _scale2.value, _scale2.value, 1.0)
              ..scaleByDouble(_scale3.value, _scale3.value, _scale3.value, 1.0)
              ..scaleByDouble(_scale4.value, _scale4.value, _scale4.value, 1.0)
              ..scaleByDouble(_scale1.value, _scale1.value, _scale1.value, 1.0),
            child: SizedBox.fromSize(
              size: Size.square(widget.size * 0.25),
              child: _itemBuilder(index),
            ),
          ),
        ),
      ),
    );
  }

  Widget _itemBuilder(int index) => widget.itemBuilder != null
      ? widget.itemBuilder!(context, index)
      : DecoratedBox(
          decoration: BoxDecoration(color: widget.color, shape: widget.shape),
        );
}
