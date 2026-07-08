import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/flow_fab_menu.dart';

class FlowFabMenuWidget extends StatefulWidget {
  const FlowFabMenuWidget({
    super.key,
    required this.items,
    this.radius = 110.0,
    this.duration = const Duration(milliseconds: 250),
    this.itemRotation = math.pi / 2,
  });

  /// The mini actions revealed around the toggle button, ordered from the
  /// "straight up" position to the "straight left" position.
  final List<FlowFabMenu> items;

  /// Distance, in logical pixels, each item travels away from the toggle
  /// button once fully open.
  final double radius;

  /// Duration of the fan-out / collapse animation.
  final Duration duration;

  /// How far (in radians) each mini item spins while collapsing back into
  /// the toggle button. At `progress == 0` (closed) an item is rotated by
  /// this full amount; at `progress == 1` (open) it sits at 0 rotation.
  final double itemRotation;

  @override
  State<FlowFabMenuWidget> createState() => _FlowFabMenuWidgetState();
}

class _FlowFabMenuWidgetState extends State<FlowFabMenuWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_controller.isDismissed) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _onItemPressed(VoidCallback onPressed) {
    _controller.reverse();
    onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final isOpen = !_controller.isDismissed;
        return Flow(
          delegate: _FlowFabMenuDelegate(
            animation: _controller,
            radius: widget.radius,
            itemRotation: widget.itemRotation,
          ),
          children: [
            for (final item in widget.items)
              IgnorePointer(
                ignoring: !isOpen,
                child: FloatingActionButton.small(
                  heroTag: null,
                  tooltip: item.tooltip,
                  onPressed: () => _onItemPressed(item.onPressed),
                  child: Icon(item.icon),
                ),
              ),
            FloatingActionButton(
              heroTag: null,
              onPressed: _toggle,
              child: AnimatedIcon(
                icon: AnimatedIcons.menu_close,
                progress: _controller,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Lays out the last child (the toggle button) at the bottom-right corner
/// of the box, and fans the preceding children out along a quarter-circle
/// arc — from directly above to directly left of the toggle — as
/// [animation] runs from 0 to 1.
class _FlowFabMenuDelegate extends FlowDelegate {
  _FlowFabMenuDelegate({
    required this.animation,
    required this.radius,
    required this.itemRotation,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final double radius;
  final double itemRotation;

  @override
  Size getSize(BoxConstraints constraints) {
    // Reserve enough room for the toggle button plus the arc items travel.
    final side = radius + 56;
    return Size(side, side);
  }

  @override
  void paintChildren(FlowPaintingContext context) {
    final toggleIndex = context.childCount - 1;
    final toggleSize = context.getChildSize(toggleIndex) ?? Size.zero;

    final toggleTopLeft = Offset(
      context.size.width - toggleSize.width,
      context.size.height - toggleSize.height,
    );
    context.paintChild(
      toggleIndex,
      transform: Matrix4.translationValues(
        toggleTopLeft.dx,
        toggleTopLeft.dy,
        0,
      ),
    );

    final toggleCenter =
        toggleTopLeft + Offset(toggleSize.width / 2, toggleSize.height / 2);
    final progress = Curves.easeOut.transform(animation.value);
    final itemCount = toggleIndex;

    for (var i = 0; i < itemCount; i++) {
      final childSize = context.getChildSize(i) ?? Size.zero;
      // Sweep from straight up (i == 0) to straight left (i == itemCount - 1).
      final theta = itemCount == 1
          ? 0.0
          : (i / (itemCount - 1)) * (math.pi / 2);
      final arcOffset = Offset(
        -radius * progress * math.sin(theta),
        -radius * progress * math.cos(theta),
      );
      final center = toggleCenter + arcOffset;
      final scale = progress.clamp(0.01, 1.0);
      // Spin back into the toggle button as it collapses (progress -> 0)
      final rotation = (1 - progress) * itemRotation;
      final halfWidth = childSize.width / 2;
      final halfHeight = childSize.height / 2;

      // Rotate and scale around the item's own center, then move that
      // center to its arc position — composed via explicit matrix
      // multiplication (non-deprecated API).
      final transform =
          Matrix4.translationValues(center.dx, center.dy, 0) *
          Matrix4.rotationZ(rotation) *
          Matrix4.diagonal3Values(scale, scale, 1.0) *
          Matrix4.translationValues(-halfWidth, -halfHeight, 0);

      context.paintChild(
        i,
        transform: transform,
        opacity: progress,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FlowFabMenuDelegate oldDelegate) {
    return oldDelegate.animation != animation || oldDelegate.radius != radius;
  }
}
