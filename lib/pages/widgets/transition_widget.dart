import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Common function to create a CustomTransitionPage with a fade transition.
/// FadeTransition
/// SlideTransition
/// ScaleTransition
/// RotationTransition
/// SizeTransition
enum PageTransitionType {
  fade,
  slideFromBottom,
  slideFromBottomFade,
  slideFromTop,
  slideFromTopFade,
  slideFromRight,
  slideFromRightFade,
  slideFromLeft,
  slideFromLeftFade,
  scale,
  rotation,
  size,
  fadeThrough,
}

/// Common function to create a CustomTransitionDialog with a fade transition.
enum DialogTransitionType {
  fadeScale,
  slideFromRight,
}

extension PageTransitionExt on PageTransitionType {
  Widget transition(Animation<double> animation, Widget child, {Animation<double>? secondaryAnimation, Curve curve = Curves.easeOut}) {
    // Ensure secondary animation is not null for avoiding ANR
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

// Custom Transition Wrapper
class TransitionPage extends CustomTransitionPage<void> {
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