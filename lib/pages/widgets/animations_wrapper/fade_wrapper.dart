import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

/// Plays the Material *fade* transition pattern on [child].
///
/// The fade pattern is used for UI elements that enter or exit within the
/// bounds of the screen — the element does not move, it only fades and
/// scales in place. Typical use cases:
///
///  * A dialog
///  * A menu
///  * A snackbar
///  * A floating action button (FAB)
///
/// Unlike its siblings [FadeThroughWrapper] and [SharedAxisTransitionWrapper],
/// this widget does not switch between two children when [child] changes.
/// Instead it plays forward/reverse whenever [animation] does.
///
/// [animation] accepts anything that implements `Animation<double>`,
/// covering two common cases:
///
///  * An [AnimationController] you own — created with a [TickerProvider]
///    (e.g. via [SingleTickerProviderStateMixin]), driven with
///    [AnimationController.forward]/[AnimationController.reverse], and
///    disposed when no longer needed.
///  * The `animation` a route's `transitionBuilder` hands you (e.g. from
///    [showGeneralDialog]), when this pattern is used as a modal transition
///    instead of an in-place toggle. In that case the Navigator owns and
///    drives the animation — do not call `forward()`/`reverse()` on it.
///
/// See also:
///
///  * [FadeScaleTransition], the underlying transition this widget wraps.
///  * [FadeThroughWrapper], for cross-fading between two unrelated children.
///  * https://m3.material.io/styles/motion/transitions/transition-patterns#fade
///    for the Material motion spec this pattern implements.
class FadeWrapper extends StatelessWidget {
  /// Creates a [FadeWrapper].
  const FadeWrapper({
    super.key,
    required this.animation,
    required this.child,
  });

  /// Drives the fade/scale transition.
  final Animation<double> animation;

  /// The widget to fade and scale in or out.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // FadeScaleTransition already listens to [animation] internally (it is
    // built on DualTransitionBuilder), so no extra AnimatedBuilder is needed
    // here — wrapping it in one would only cause redundant rebuilds.
    return FadeScaleTransition(
      animation: animation,
      child: child,
    );
  }
}
