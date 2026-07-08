import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

/// Plays the Material *shared axis* transition pattern whenever [child]
/// changes.
///
/// The shared axis pattern is used for transitions between UI elements that
/// have a spatial or navigational relationship. It applies a shared
/// transformation along the x, y, or z axis (see [transitionType]) to
/// reinforce that relationship. Typical use cases:
///
///  * An onboarding flow transitioning along the x-axis
///    ([SharedAxisTransitionType.horizontal])
///  * A stepper transitioning along the y-axis
///    ([SharedAxisTransitionType.vertical])
///  * Parent-child navigation transitioning along the z-axis
///    ([SharedAxisTransitionType.scaled])
///
/// Internally this wraps [PageTransitionSwitcher] with a
/// [SharedAxisTransition] builder.
///
/// Important: [PageTransitionSwitcher] only animates when the new [child]
/// has a different [Type] or [Key] than the previous one (see
/// [Widget.canUpdate]). Give each distinct piece of content a stable, unique
/// [Key] (typically a [ValueKey]) or the switch will apply instantly instead
/// of animating.
///
/// See also:
///
///  * [SharedAxisTransition], the underlying transition this widget wraps.
///  * [FadeThroughWrapper], for elements with no strong relationship instead.
///  * https://m3.material.io/styles/motion/transitions/transition-patterns#shared-axis
///    for the Material motion spec this pattern implements.
class SharedAxisTransitionWrapper extends StatelessWidget {
  /// Creates a [SharedAxisTransitionWrapper].
  const SharedAxisTransitionWrapper({
    super.key,
    required this.transitionType,
    required this.child,
    this.isReverse = false,
    this.duration = const Duration(milliseconds: 300),
    this.fillColor,
    this.layoutBuilder = PageTransitionSwitcher.defaultLayoutBuilder,
  });

  /// Whether the new [child] transitions in *below* the old one (`true`,
  /// similar to popping a route) instead of on top of it (`false`, similar
  /// to pushing a route).
  final bool isReverse;

  /// Which axis (x, y, or z) the shared transformation runs along.
  final SharedAxisTransitionType transitionType;

  /// The current content to display.
  ///
  /// When this changes to a widget with a different type or [Key], the old
  /// content transitions out and this new one transitions in along
  /// [transitionType]'s axis.
  final Widget child;

  /// How long the transition takes.
  ///
  /// Defaults to 300ms, matching [PageTransitionSwitcher]'s own default.
  final Duration duration;

  /// The color shown behind the content while it transitions between states.
  ///
  /// Defaults to the ambient [ThemeData.canvasColor].
  final Color? fillColor;

  /// Lays out the outgoing and incoming children while both are present
  /// during the transition.
  ///
  /// Defaults to [PageTransitionSwitcher.defaultLayoutBuilder], which stacks
  /// and centers them.
  final PageTransitionSwitcherLayoutBuilder layoutBuilder;

  @override
  Widget build(BuildContext context) {
    return PageTransitionSwitcher(
      duration: duration,
      reverse: isReverse,
      layoutBuilder: layoutBuilder,
      transitionBuilder: (
        Widget child,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
      ) {
        return SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: transitionType,
          fillColor: fillColor,
          child: child,
        );
      },
      child: child,
    );
  }
}
