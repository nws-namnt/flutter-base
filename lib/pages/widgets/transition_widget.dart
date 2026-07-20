import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Route transition styles for [TransitionPage].
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

  /// Material shared axis — horizontal (x-axis), for parent-child
  /// navigation, e.g. drilling into a settings sub-page
  /// (uses the `animations` package).
  sharedAxisHorizontal,

  /// Material shared axis — vertical (y-axis), e.g. a stepper
  /// (uses the `animations` package).
  sharedAxisVertical,

  /// Material shared axis — scaled (z-axis), e.g. parent-child navigation
  /// with a zoom emphasis (uses the `animations` package).
  sharedAxisScaled;
}

extension PageTransitionExt on PageTransitionType {
  /// Wraps [child] with the appropriate transition widget.
  ///
  /// [animation] is the forward animation; [secondaryAnimation] is used by
  /// [PageTransitionType.fadeThrough] for the outgoing page. Falls back to
  /// [animation] when [secondaryAnimation] is null to avoid null-safety issues.
  Widget transition(
      Animation<double> animation,
      Widget child, {
        Animation<double>? secondaryAnimation,
        Curve curve = Curves.easeOut,
        Curve reverseCurve = Curves.easeIn,
      }) {
    // Wrap both animations in CurvedAnimation to apply the easing curve.
    // secondaryAnimation fallback prevents ANR from a null dereference.
    final Animation<double> primary = CurvedAnimation(
      parent: animation,
      curve: curve,
      reverseCurve: reverseCurve,
    );
    final Animation<double> secondary = CurvedAnimation(
      parent: secondaryAnimation ?? animation,
      curve: Curves.easeIn,
      reverseCurve: Curves.easeOut,
    );

    switch (this) {
      case .fadeThrough:
        return FadeThroughTransition(
          animation: primary,
          secondaryAnimation: secondary,
          child: child,
        );
      case .fade:
        return FadeTransition(
          opacity: Tween<double>(begin: 0, end: 1).animate(primary),
          child: child,
        );
      case .slideFromTopFade:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: .zero,
          ).animate(primary),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0, end: 1).animate(primary),
            child: child,
          ),
        );
      case .slideFromBottomFade:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: .zero,
          ).animate(primary),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0, end: 1).animate(primary),
            child: child,
          ),
        );
      case .slideFromLeftFade:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1, 0),
            end: .zero,
          ).animate(primary),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0, end: 1).animate(primary),
            child: child,
          ),
        );
      case .slideFromRightFade:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: .zero,
          ).animate(primary),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0, end: 1).animate(primary),
            child: child,
          ),
        );
      case .slideFromTop:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: .zero,
          ).animate(primary),
          child: child,
        );
      case .slideFromBottom:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: .zero,
          ).animate(primary),
          child: child,
        );
      case .slideFromLeft:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1, 0),
            end: .zero,
          ).animate(primary),
          child: child,
        );
      case .slideFromRight:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: .zero,
          ).animate(primary),
          child: child,
        );
      case .scale:
        return ScaleTransition(
          scale: Tween<double>(begin: 0, end: 1).animate(primary),
          child: child,
        );
      case .rotation:
        return RotationTransition(
          turns: Tween<double>(begin: 0, end: 1).animate(primary),
          child: child,
        );
      case .size:
        return Align(
          alignment: Alignment.center,
          child: SizeTransition(
            sizeFactor: primary,
            child: child,
          ),
        );
      case .sharedAxisHorizontal:
        return SharedAxisTransition(
          animation: primary,
          secondaryAnimation: secondary,
          transitionType: .horizontal,
          child: child,
        );
      case .sharedAxisVertical:
        return SharedAxisTransition(
          animation: primary,
          secondaryAnimation: secondary,
          transitionType: .vertical,
          child: child,
        );
      case .sharedAxisScaled:
        return SharedAxisTransition(
          animation: primary,
          secondaryAnimation: secondary,
          transitionType: .scaled,
          child: child,
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
    PageTransitionType? reverseTransitionType,
    Curve curve = Curves.easeOut,
    Curve reverseCurve = Curves.easeIn,
    super.barrierColor,
    super.opaque,
  }) : super(
         key: key ?? ValueKey('$transitionType-${child.hashCode}'),
         transitionDuration:
             transitionDuration ?? const Duration(milliseconds: 350),
         reverseTransitionDuration:
             reverseTransitionDuration ?? const Duration(milliseconds: 350),
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           final isReverse = animation.status == .reverse;
           final type = isReverse ? reverseTransitionType ?? transitionType : transitionType;

           return type.transition(
             animation,
             child,
             secondaryAnimation: secondaryAnimation,
             curve: curve,
             reverseCurve: reverseCurve,
           );
         },
       );
}
