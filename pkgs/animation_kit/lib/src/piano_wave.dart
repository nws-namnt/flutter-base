import 'package:flutter/widgets.dart';

import 'delay_tween.dart';

/// Determines which end of a [PianoWave] row the animation wave appears to
/// originate from.
enum PianoWaveType {
  /// Wave starts from the leftmost bar.
  start,

  /// Wave starts from the rightmost bar.
  end,

  /// Wave starts from the center bar and spreads outward.
  center,
}

/// A row of bars that scale horizontally like piano keys, with the phase
/// offsets of the [DelayTween] driving each bar chosen by [type] so the
/// wave appears to originate from the start, end, or center of the row.
class PianoWave extends StatefulWidget {
  const PianoWave({
    super.key,
    this.color,
    this.type = PianoWaveType.start,
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

  /// Color of each bar. Ignored if [itemBuilder] is provided.
  final Color? color;

  /// Number of bars in the row; must be at least `2`.
  final int itemCount;

  /// The size of the square box that contains the animation. Defaults to `50.0`.
  final double size;

  /// Which end of the row the wave appears to originate from. Defaults to
  /// [PianoWaveType.start].
  final PianoWaveType type;

  /// Optional builder used to render each bar instead of the default
  /// color-filled box.
  final IndexedWidgetBuilder? itemBuilder;

  /// Duration of one full animation cycle. Defaults to `1200ms`.
  final Duration duration;

  /// Optional external controller driving the animation. If not provided, an
  /// internal repeating controller is created and disposed automatically.
  final AnimationController? controller;

  @override
  State<PianoWave> createState() => _PianoWaveState();
}

class _PianoWaveState extends State<PianoWave> with SingleTickerProviderStateMixin {
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
            return DottedScaleXWidget(
              scaleX: DelayTween(
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
      case PianoWaveType.start:
        return _startAnimationDelay(itemCount);
      case PianoWaveType.end:
        return _endAnimationDelay(itemCount);
      case PianoWaveType.center:
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

/// Scales its [child] horizontally (X axis only) according to the given
/// `scaleX` animation, used by [PianoWave] to squeeze/stretch each bar.
class DottedScaleXWidget extends AnimatedWidget {
  const DottedScaleXWidget({
    super.key,
    required Animation<double> scaleX,
    required this.child,
    this.alignment = Alignment.center,
  }) : super(listenable: scaleX);

  /// The widget to scale horizontally.
  final Widget child;

  /// Alignment used as the origin point for the horizontal scaling.
  /// Defaults to [Alignment.center].
  final Alignment alignment;

  /// The horizontal scale animation driving this widget.
  Animation<double> get scale => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.identity()..scaleByDouble(scale.value * 0.8, 1.0, 1.0, 1.0),
      alignment: alignment,
      child: child,
    );
  }
}
