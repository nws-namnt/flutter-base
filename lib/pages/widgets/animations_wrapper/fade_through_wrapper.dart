import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

/// Plays the Material *fade through* transition pattern whenever [child]
/// changes.
///
/// The fade through pattern is used for transitions between UI elements that
/// do not have a strong relationship to each other. Typical use cases:
///
///  * Tapping destinations in a bottom navigation bar
///  * Tapping a refresh icon
///  * Tapping an account switcher
///
/// Internally this wraps [PageTransitionSwitcher] with a
/// [FadeThroughTransition] builder: the outgoing content fades out first,
/// then the incoming content fades in and scales up slightly.
///
/// Important: [PageTransitionSwitcher] only animates when the new [child]
/// has a different [Type] or [Key] than the previous one (see
/// [Widget.canUpdate]). Give each distinct piece of content a stable, unique
/// [Key] (typically a [ValueKey]) or the switch will apply instantly instead
/// of animating.
///
/// See also:
///
///  * [FadeThroughTransition], the underlying transition this widget wraps.
///  * [SharedAxisTransitionWrapper], for elements with a spatial or
///    navigational relationship instead.
///  * https://m3.material.io/styles/motion/transitions/transition-patterns#fade-through
///    for the Material motion spec this pattern implements.
class FadeThroughWrapper extends StatelessWidget {
  /// Creates a [FadeThroughWrapper].
  const FadeThroughWrapper({
    super.key,
    required this.child,
    this.isReverse = false,
    this.duration = const Duration(milliseconds: 300),
    this.fillColor,
    this.layoutBuilder = PageTransitionSwitcher.defaultLayoutBuilder,
  });

  /// The current content to display.
  ///
  /// When this changes to a widget with a different type or [Key], the old
  /// content fades out and this new one fades in.
  final Widget child;

  /// Whether the new [child] transitions in *below* the old one (`true`,
  /// similar to popping a route) instead of on top of it (`false`, similar
  /// to pushing a route).
  final bool isReverse;

  /// How long the fade-out/fade-in transition takes.
  ///
  /// Defaults to 300ms, matching [PageTransitionSwitcher]'s own default.
  final Duration duration;

  /// The color shown behind the content while it fades between states.
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
        return FadeThroughTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          fillColor: fillColor,
          child: child,
        );
      },
      child: child,
    );
  }
}
