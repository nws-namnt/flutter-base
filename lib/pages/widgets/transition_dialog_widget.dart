import 'package:flutter/material.dart';

/// Transition styles for full-screen dialogs.
enum DialogTransitionType {
  /// Fade only.
  fade,

  /// Fade + scale up from 95% (Material default look).
  fadeScale,

  /// Scale up from 0 with fade.
  scale,

  /// Slide in from the right edge (+ fade).
  slideFromRight,

  /// Slide in from the left edge (+ fade).
  slideFromLeft,

  /// Slide down from the top edge (+ fade).
  slideFromTop,

  /// Slide up from the bottom edge (+ fade).
  slideFromBottom,

  /// 360° rotation with fade.
  rotation,

  /// Expand from zero height, centered.
  size;
}

extension DialogTransitionExt on DialogTransitionType {
  /// Wraps [child] with the transition described by `this`.
  ///
  /// [animation] is the forward (entry) animation, driven by the route.
  /// [secondaryAnimation] is accepted for API symmetry with the page
  /// transition helper; the current cases don't use it.
  /// [curve] is applied on entry and [reverseCurve] on exit (the enclosing
  /// [CurvedAnimation] swaps automatically when the route animation reverses).
  Widget transition(
    Animation<double> animation,
    Widget child, {
    Animation<double>? secondaryAnimation,
    Curve curve = Curves.easeOut,
    Curve reverseCurve = Curves.easeIn,
  }) {
    final Animation<double> primary = CurvedAnimation(
      parent: animation,
      curve: curve,
      reverseCurve: reverseCurve,
    );
    final Animation<double> fade =
        Tween<double>(begin: 0, end: 1).animate(primary);

    return switch (this) {
      .fade => FadeTransition(opacity: fade, child: child),
      .fadeScale => FadeTransition(
        opacity: fade,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.95, end: 1).animate(primary),
          child: child,
        ),
      ),
      .scale => FadeTransition(
        opacity: fade,
        child: ScaleTransition(scale: primary, child: child),
      ),
      .slideFromRight => FadeTransition(
        opacity: fade,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: .zero,
          ).animate(primary),
          child: child,
        ),
      ),
      .slideFromLeft => FadeTransition(
        opacity: fade,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1, 0),
            end: .zero,
          ).animate(primary),
          child: child,
        ),
      ),
      .slideFromTop => FadeTransition(
        opacity: fade,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: .zero,
          ).animate(primary),
          child: child,
        ),
      ),
      .slideFromBottom => FadeTransition(
        opacity: fade,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: .zero,
          ).animate(primary),
          child: child,
        ),
      ),
      .rotation => FadeTransition(
        opacity: fade,
        child: RotationTransition(turns: primary, child: child),
      ),
      .size => FadeTransition(
        opacity: fade,
        child: Align(
          alignment: Alignment.center,
          child: SizeTransition(sizeFactor: primary, child: child),
        ),
      ),
    };
  }
}

/// A [RawDialogRoute] preconfigured with a [DialogTransitionType].
///
/// This is the dialog equivalent of `TransitionPage`. [RawDialogRoute] is the
/// exact route [showGeneralDialog] pushes internally, so a [TransitionDialog]
/// can be pushed directly onto a [Navigator] when a reusable route object is
/// needed (e.g. `onGenerateRoute`); for the common "just open a dialog" case,
/// prefer `context.showCustomDialog` or a `RouteDialogWidget`.
///
/// Unlike [showDialog], [RawDialogRoute] does NOT wrap [pageBuilder]'s result
/// in a [Dialog]/[Material]; the builder must provide its own [Material]
/// ancestor (e.g. [AlertDialog], [Dialog], [Card], or [Material]).
///
/// Example:
/// ```dart
/// final ok = await Navigator.of(context).push(
///   TransitionDialog<bool>(
///     transitionType: DialogTransitionType.slideFromRight,
///     pageBuilder: (context, _, __) => const MyDialog(),
///   ),
/// );
/// ```
class TransitionDialog<T> extends RawDialogRoute<T> {
  /// Creates a [TransitionDialog].
  ///
  /// [transitionType] selects the entry animation and [curve] shapes it.
  /// [reverseTransitionType] / [reverseCurve] / [reverseTransitionDuration]
  /// control the exit and default to mirroring the entry
  /// ([reverseTransitionType] falls back to [transitionType]; the duration
  /// falls back to [transitionDuration]).
  TransitionDialog({
    required super.pageBuilder,
    DialogTransitionType transitionType = .fadeScale,
    DialogTransitionType? reverseTransitionType,
    Curve curve = Curves.easeOut,
    Curve reverseCurve = Curves.easeIn,
    super.transitionDuration = const Duration(milliseconds: 250),
    Duration? reverseTransitionDuration,
    super.barrierDismissible,
    super.barrierLabel,
    super.barrierColor,
    super.settings,
    super.anchorPoint,
    super.requestFocus,
    super.traversalEdgeBehavior,
    super.directionalTraversalEdgeBehavior,
    super.fullscreenDialog,
  })  : _reverseTransitionDuration = reverseTransitionDuration,
        super(
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          // A dialog route runs its animation in reverse while closing; swap
          // to the reverse transition type for that phase (reverseCurve is
          // applied by the CurvedAnimation inside transition()).
          final isReverse = animation.status == AnimationStatus.reverse;
          final type = isReverse
              ? (reverseTransitionType ?? transitionType)
              : transitionType;

          return type.transition(
            animation,
            child,
            secondaryAnimation: secondaryAnimation,
            curve: curve,
            reverseCurve: reverseCurve,
          );
        },
      );

  final Duration? _reverseTransitionDuration;

  /// Overrides [TransitionRoute.reverseTransitionDuration] (which otherwise
  /// defaults to [transitionDuration]). The framework reads this getter when
  /// creating the route's animation controller, so the close animation can run
  /// for a different duration than the open one.
  @override
  Duration get reverseTransitionDuration =>
      _reverseTransitionDuration ?? transitionDuration;
}