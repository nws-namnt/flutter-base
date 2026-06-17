import 'package:flutter/material.dart';

import 'transition_shell_widget.dart';

/// Renders all navigation branches in a [Stack], keeping inactive branches
/// in an [Offstage] so their state is preserved. The newly activated branch
/// animates in using [transitionType].
///
/// The [CurvedAnimation] and [Tween] are stored as long-lived fields to
/// avoid listener accumulation on repeated tab switches.
class AnimatedBranchContainer extends StatefulWidget {
  const AnimatedBranchContainer({
    super.key,
    required this.currentIndex,
    required this.children,
    this.transitionType = ShellTransitionType.slide,
    this.curve = Curves.easeOut,
    this.duration = const Duration(milliseconds: 220),
  });

  final int currentIndex;
  final List<Widget> children;
  final ShellTransitionType transitionType;
  final Curve curve;
  final Duration duration;

  @override
  State<AnimatedBranchContainer> createState() =>
      _AnimatedBranchContainerState();
}

class _AnimatedBranchContainerState extends State<AnimatedBranchContainer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _curved;
  late final Tween<Offset> _tween;
  late final Animation<Offset> _slideIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
      value: 1.0, // start fully visible on first render
    );
    _curved = CurvedAnimation(parent: _controller, curve: widget.curve);
    _tween = Tween<Offset>(begin: Offset.zero, end: Offset.zero);
    _slideIn = _tween.animate(_curved);
  }

  @override
  void didUpdateWidget(AnimatedBranchContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _tween.begin = const Offset(-1, 0);
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _curved.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: widget.children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        final isActive = index == widget.currentIndex;

        return Offstage(
          offstage: !isActive,
          child: RepaintBoundary(
            child: isActive
                ? widget.transitionType.transition(
                    child: child,
                    opacity: _curved,
                    position: _slideIn,
                  )
                : child,
          ),
        );
      }).toList(),
    );
  }
}
