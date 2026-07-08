import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Four circles that cycle through a row, where the leading circle fades
/// and grows in while the trailing circle fades and shrinks out; once a
/// forward pass completes, the widget list is rotated and, after [delay],
/// the animation restarts to give a continuous "in and out" cycling effect.
class ThreeInOut extends StatefulWidget {
  const ThreeInOut({
    super.key,
    this.color,
    this.size = 50.0,
    this.itemBuilder,
    this.duration = const Duration(milliseconds: 500),
    this.delay = const Duration(milliseconds: 50),
    this.controller,
  })  : assert(
          !(itemBuilder is IndexedWidgetBuilder && color is Color) && !(itemBuilder == null && color == null),
          'You should specify either a itemBuilder or a color',
        );

  /// Color of each circle. Ignored if [itemBuilder] is provided. Either this
  /// or [itemBuilder] must be specified.
  final Color? color;

  /// Overall width/height of the row; the row's width is `size * 2` and each
  /// circle is `size * 0.5`. Defaults to `50.0`.
  final double size;

  /// Custom builder used to render each circle instead of the default
  /// [color]-filled circle. Either this or [color] must be specified.
  final IndexedWidgetBuilder? itemBuilder;

  /// Duration of one forward fade/scale pass. Defaults to `500` milliseconds.
  final Duration duration;

  /// Pause between the end of one forward animation pass and the start of
  /// the next.
  final Duration delay;

  /// Optional external controller. If null, an internal one is created and
  /// disposed automatically.
  final AnimationController? controller;

  @override
  State<ThreeInOut> createState() => _ThreeInOutState();
}

class _ThreeInOutState extends State<ThreeInOut> with SingleTickerProviderStateMixin {
  late AnimationController? _controller;

  late List<Widget> _widgets;

  Timer? _forwardTimer;

  double _lastAnim = 0;

  @override
  void initState() {
    super.initState();

    // Create a extra element which is used for the show/hide animation.
    _widgets = List.generate(
      4,
      (i) => SizedBox.fromSize(
        size: Size.square(widget.size * 0.5),
        child: _itemBuilder(i),
      ),
    );

    _controller = widget.controller ?? AnimationController(vsync: this, duration: widget.duration);

    _controller!.forward();

    _controller!.addListener(() {
      if (_lastAnim > _controller!.value) {
        if (mounted) {
          setState(() => _widgets.insert(0, _widgets.removeLast()));
        }
      }

      _lastAnim = _controller!.value;

      if (_controller!.isCompleted) {
        _forwardTimer = Timer(
          widget.delay,
          () => _controller?.forward(from: 0),
        );
      }
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller?.dispose();
      _controller = null;
    }

    _forwardTimer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox.fromSize(
        size: Size(widget.size * 2, widget.size),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: _widgets
              .asMap()
              .map((index, value) {
                Widget innerWidget = value;

                if (index == 0) {
                  innerWidget = _wrapInAnimatedBuilder(innerWidget);
                } else if (index == 3) {
                  innerWidget = _wrapInAnimatedBuilder(
                    innerWidget,
                    inverse: true,
                  );
                }

                return MapEntry<int, Widget>(index, innerWidget);
              })
              .values
              .toList(),
        ),
      ),
    );
  }

  AnimatedBuilder _wrapInAnimatedBuilder(
    Widget innerWidget, {
    bool inverse = false,
  }) {
    return AnimatedBuilder(
      animation: _controller!,
      child: innerWidget,
      builder: (context, inn) {
        final value = inverse ? 1 - _controller!.value : _controller!.value;
        return SizedBox.fromSize(
          size: Size.square(widget.size * 0.5 * value),
          child: Opacity(opacity: value, child: inn),
        );
      },
    );
  }

  Widget _itemBuilder(int index) => widget.itemBuilder != null
      ? widget.itemBuilder!(context, index)
      : DecoratedBox(
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
          ),
        );
}
