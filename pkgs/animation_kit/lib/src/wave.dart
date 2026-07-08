import 'package:flutter/widgets.dart';

import 'delay_tween.dart';

/// Determines where the [Wave] animation appears to originate from.
enum WaveType {
  /// The wave appears to originate from the start (left) of the row.
  start,

  /// The wave appears to originate from the end (right) of the row.
  end,

  /// The wave appears to originate from the center of the row.
  center,
}

/// A row of bars that scale vertically like a sound-level meter, with the
/// phase offsets of the [DelayTween] driving each bar chosen by [type] so
/// the wave appears to originate from the start, end, or center of the row.
class Wave extends StatefulWidget {
  const Wave({
    super.key,
    this.color,
    this.type = WaveType.start,
    this.size = 50.0,
    this.itemBuilder,
    this.itemCount = 5,
    this.duration = const Duration(milliseconds: 1200),
    this.controller,
  })  : assert(
          !(itemBuilder is IndexedWidgetBuilder && color is Color) && !(itemBuilder == null && color == null),
          'You should specify either a itemBuilder or a color',
        ),
        assert(itemCount >= 2, 'itemCount Cant be less then 2 ');

  /// Color of each bar. Ignored if [itemBuilder] is provided. Either this
  /// or [itemBuilder] must be specified.
  final Color? color;

  /// Number of bars in the row; must be at least `2`.
  final int itemCount;

  /// Overall width/height of the row; the row's width is `size * 1.25` and
  /// each bar's width is `size / itemCount`. Defaults to `50.0`.
  final double size;

  /// Where the wave appears to originate from. Defaults to
  /// [WaveType.start].
  final WaveType type;

  /// Custom builder used to render each bar instead of the default
  /// [color]-filled box. Either this or [color] must be specified.
  final IndexedWidgetBuilder? itemBuilder;

  /// Duration of one full wave cycle. Defaults to `1200` milliseconds.
  final Duration duration;

  /// Optional external controller. If null, an internal one is created and
  /// disposed automatically.
  final AnimationController? controller;

  @override
  State<Wave> createState() => _WaveState();
}

class _WaveState extends State<Wave> with SingleTickerProviderStateMixin {
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
    final List<double> bars = getAnimationDelay(widget.itemCount);
    return Center(
      child: SizedBox.fromSize(
        size: Size(widget.size * 1.25, widget.size),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(bars.length, (i) {
            return ScaleYWidget(
              scaleY: DelayTween(
                begin: .4,
                end: 1.0,
                delay: bars[i],
              ).animate(_controller),
              child: SizedBox.fromSize(
                size: Size(widget.size / widget.itemCount, widget.size),
                child: _itemBuilder(i),
              ),
            );
          }),
        ),
      ),
    );
  }

  List<double> getAnimationDelay(int itemCount) {
    switch (widget.type) {
      case WaveType.start:
        return _startAnimationDelay(itemCount);
      case WaveType.end:
        return _endAnimationDelay(itemCount);
      case WaveType.center:
        return _centerAnimationDelay(itemCount);
    }
  }

  List<double> _startAnimationDelay(int count) {
    return <double>[
      ...List<double>.generate(
        count ~/ 2,
        (index) => -1.0 - (index * 0.1) - 0.1,
      ).reversed,
      if (count.isOdd) -1.0,
      ...List<double>.generate(
        count ~/ 2,
        (index) => -1.0 + (index * 0.1) + (count.isOdd ? 0.1 : 0.0),
      ),
    ];
  }

  List<double> _endAnimationDelay(int count) {
    return <double>[
      ...List<double>.generate(
        count ~/ 2,
        (index) => -1.0 + (index * 0.1) + 0.1,
      ).reversed,
      if (count.isOdd) -1.0,
      ...List<double>.generate(
        count ~/ 2,
        (index) => -1.0 - (index * 0.1) - (count.isOdd ? 0.1 : 0.0),
      ),
    ];
  }

  List<double> _centerAnimationDelay(int count) {
    return <double>[
      ...List<double>.generate(
        count ~/ 2,
        (index) => -1.0 + (index * 0.2) + 0.2,
      ).reversed,
      if (count.isOdd) -1.0,
      ...List<double>.generate(
        count ~/ 2,
        (index) => -1.0 + (index * 0.2) + 0.2,
      ),
    ];
  }

  Widget _itemBuilder(int index) => widget.itemBuilder != null
      ? widget.itemBuilder!(context, index)
      : DecoratedBox(decoration: BoxDecoration(color: widget.color));
}

/// Scales its [child] vertically (Y axis only) according to the given
/// `scaleY` animation, used by [Wave] to stretch/squeeze each bar.
class ScaleYWidget extends AnimatedWidget {
  const ScaleYWidget({
    super.key,
    /// The vertical scale animation to apply to [child].
    required Animation<double> scaleY,
    required this.child,
    this.alignment = Alignment.center,
  }) : super(listenable: scaleY);

  /// The widget being scaled vertically.
  final Widget child;

  /// Alignment used as the origin of the vertical scaling. Defaults to
  /// [Alignment.center].
  final Alignment alignment;

  /// The current vertical scale animation, exposed from the [scaleY]
  /// listenable passed to the constructor.
  Animation<double> get scale => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.identity()..scaleByDouble(1.0, scale.value, 1.0, 1.0),
      alignment: alignment,
      child: child,
    );
  }
}
