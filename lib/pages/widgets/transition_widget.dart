import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Route transition styles for [TransitionPage].
///
/// Pass a value to [TransitionPage]'s `transitionType` parameter to control
/// how the page animates in. The animation is applied by [PageTransitionExt.transition].
enum PageTransitionType {
  /// Cross-fade.
  fade,

  /// Slide in from the bottom edge.
  slideFromBottom,

  /// Slide in from the bottom edge with a simultaneous fade-in.
  slideFromBottomFade,

  /// Slide in from the top edge.
  slideFromTop,

  /// Slide in from the top edge with a simultaneous fade-in.
  slideFromTopFade,

  /// Slide in from the right edge (standard forward navigation).
  slideFromRight,

  /// Slide in from the right edge with a simultaneous fade-in.
  slideFromRightFade,

  /// Slide in from the left edge (back navigation).
  slideFromLeft,

  /// Slide in from the left edge with a simultaneous fade-in.
  slideFromLeftFade,

  /// Scale up from 0 to 1 (zoom-in).
  scale,

  /// Full 360 ° rotation.
  rotation,

  /// Expand from zero size.
  size,

  /// Material fade-through (uses the `animations` package).
  fadeThrough,
}

/// Transition styles for full-screen dialogs.
enum DialogTransitionType {
  /// Fade + scale (Material shared-axis equivalent).
  fadeScale,

  /// Slide in from the right edge.
  slideFromRight,
}

/// Extension that converts a [PageTransitionType] into a concrete transition widget.
extension PageTransitionExt on PageTransitionType {
  /// Wraps [child] with the appropriate transition widget.
  ///
  /// [animation] is the forward animation; [secondaryAnimation] is used by
  /// [PageTransitionType.fadeThrough] for the outgoing page. Falls back to
  /// [animation] when [secondaryAnimation] is null to avoid null-safety issues.
  Widget transition(Animation<double> animation, Widget child, {Animation<double>? secondaryAnimation, Curve curve = Curves.easeOut}) {
    // Wrap both animations in CurvedAnimation to apply the easing curve.
    // secondaryAnimation fallback prevents ANR from a null dereference.
    final Animation<double> primary = CurvedAnimation(parent: animation, curve: curve);
    final Animation<double> secondary = CurvedAnimation(parent: secondaryAnimation ?? animation, curve: Curves.easeIn);

    switch(this) {
      case PageTransitionType.fadeThrough:
        return FadeThroughTransition(animation: primary, secondaryAnimation: secondary, child: child);
      case PageTransitionType.fade:
        return FadeTransition(opacity: Tween<double>(begin: 0, end: 1).animate(primary), child: child);
      case PageTransitionType.slideFromTopFade:
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
              .animate(primary),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0, end: 1).animate(primary),
            child: child,
          ),
        );
      case PageTransitionType.slideFromBottomFade:
        return SlideTransition(
          position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero
          ).animate(primary),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0, end: 1).animate(primary),
            child: child,
          ),
        );
      case PageTransitionType.slideFromLeftFade:
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero)
              .animate(primary),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0, end: 1).animate(primary),
            child: child,
          ),
        );
      case PageTransitionType.slideFromRightFade:
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(primary),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0, end: 1).animate(primary),
            child: child,
          ),
        );
      case PageTransitionType.slideFromTop:
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
              .animate(primary),
          child: child,
        );
      case PageTransitionType.slideFromBottom:
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(primary),
          child: child,
        );
      case PageTransitionType.slideFromLeft:
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero)
              .animate(primary),
          child: child,
        );
      case PageTransitionType.slideFromRight:
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(primary),
          child: child,
        );
      case PageTransitionType.scale:
        return ScaleTransition(
          scale: Tween<double>(begin: 0, end: 1).animate(primary),
          child: child,
        );
      case PageTransitionType.rotation:
        return RotationTransition(
          turns: Tween<double>(begin: 0, end: 1).animate(primary),
          child: child,
        );
      case PageTransitionType.size:
        return Align(
          alignment: Alignment.center,
          child: SizeTransition(
              sizeFactor: primary,
              alignment: AlignmentGeometry.center,
              child: child
          ),
        );
    }
  }
}

/// A [CustomTransitionPage] preconfigured with a [PageTransitionType].
///
/// Use this as the return value of a GoRoute's `pageBuilder`:
///
/// ```dart
/// pageBuilder: (context, state) => TransitionPage(
///   child: const MyPage(),
///   transitionType: PageTransitionType.slideFromRight,
/// ),
/// ```
///
/// A stable [ValueKey] is derived from [transitionType] + [child.hashCode]
/// so GoRouter does not re-build the page unnecessarily.
class TransitionPage extends CustomTransitionPage<void> {
  /// Creates a [TransitionPage].
  ///
  /// [transitionDuration] and [reverseTransitionDuration] default to 350 ms.
  TransitionPage({
    LocalKey? key,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
    required super.child,
    required PageTransitionType transitionType,
    Curve curve = Curves.easeOut,
  }) : super(
    key: key ?? ValueKey('$transitionType-${child.hashCode}'),
    transitionDuration: transitionDuration ?? const Duration(milliseconds: 350),
    reverseTransitionDuration: reverseTransitionDuration ?? const Duration(milliseconds: 350),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return transitionType.transition(animation, child, secondaryAnimation: secondaryAnimation);
    }
  );
}