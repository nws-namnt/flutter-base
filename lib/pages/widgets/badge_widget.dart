import 'package:flutter/material.dart';

/// Visual effect played when [BadgeWidget.badgeCount] increases.
enum BadgeAnimationEffectType {
  /// Pop: scales up then settles back.
  scale,

  /// Shake: a quick horizontal wiggle.
  shake,

  /// Fade combined with an upward slide-in.
  fadeSlide,
}

/// A Material [Badge] that animates each time [badgeCount] increases and hides
/// itself when the count is zero.
///
/// Pick the effect via the named constructors: [BadgeWidget.scale],
/// [BadgeWidget.shake], or [BadgeWidget.fadeSlide]. Pass [child] to anchor the
/// badge to a widget, or omit it to render a standalone badge.
class BadgeWidget extends StatefulWidget {
  /// Creates a badge that pops (scales) when the count increases.
  const BadgeWidget.scale({
    super.key,
    required this.badgeCount,
    this.child,
  }) : animationEffect = BadgeAnimationEffectType.scale;

  /// Creates a badge that shakes when the count increases.
  const BadgeWidget.shake({
    super.key,
    required this.badgeCount,
    this.child,
  }) : animationEffect = BadgeAnimationEffectType.shake;

  /// Creates a badge that fades and slides in when the count increases.
  const BadgeWidget.fadeSlide({
    super.key,
    required this.badgeCount,
    this.child,
  }) : animationEffect = BadgeAnimationEffectType.fadeSlide;

  /// The number shown in the badge. When `<= 0` the badge is hidden.
  final int badgeCount;

  /// Optional widget the badge is anchored to; standalone when null.
  final Widget? child;

  /// Which animation plays on each increment of [badgeCount].
  final BadgeAnimationEffectType animationEffect;

  @override
  State<BadgeWidget> createState() => _BadgeWidgetState();
}

class _BadgeWidgetState extends State<BadgeWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  late final Animation<double>? _scale;
  late final Animation<double>? _shake;
  late final Animation<double>? _fade;
  late final Animation<Offset>? _slide;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 1.0,
    );

    switch(widget.animationEffect) {
      case BadgeAnimationEffectType.scale:
        _scale = TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.4).chain(CurveTween(curve: Curves.easeOut)), weight: 40),
          TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)), weight: 60),
        ]).animate(_animationController);
        _shake = null;
        _fade = null;
        _slide = null;
        break;
      case BadgeAnimationEffectType.shake:
        _shake = TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0.0, end: 8.0), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 8.0, end: -8.0), weight: 2),
          TweenSequenceItem(tween: Tween(begin: -8.0, end: 5.0), weight: 2),
          TweenSequenceItem(tween: Tween(begin: 5.0, end: -5.0), weight: 2),
          TweenSequenceItem(tween: Tween(begin: -5.0, end: 0.0), weight: 1),
        ]).animate(CurvedAnimation(parent: _animationController, curve: Curves.linear));
        _scale = null;
        _fade = null;
        _slide = null;
        break;
      case BadgeAnimationEffectType.fadeSlide:
        _fade = CurvedAnimation(parent: _animationController, curve: Curves.easeOut);
        _slide = Tween<Offset>(
          begin: const Offset(0, 0.6),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack));
        _scale = null;
        _shake = null;
        break;
    }

    if (widget.badgeCount > 0 &&
        widget.animationEffect == BadgeAnimationEffectType.fadeSlide) {
      _animationController.forward(from: 0);
    }
  }

  @override
  void didUpdateWidget(covariant BadgeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.badgeCount > oldWidget.badgeCount) {
      _animationController.forward(from: 0);  // Only bounce when the count actually increases
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.badgeCount <= 0) return widget.child ?? const SizedBox.shrink();

    return switch(widget.animationEffect) {
      BadgeAnimationEffectType.scale => _BadgeScaleAnimation(listenable: _scale!, label: '${widget.badgeCount}', child: widget.child),
      BadgeAnimationEffectType.shake => _BadgeShakeAnimation(listenable: _shake!, label: '${widget.badgeCount}', child: widget.child),
      BadgeAnimationEffectType.fadeSlide => FadeTransition(
        opacity: _fade!,
        child: SlideTransition(
          position: _slide!,
          child: Badge(label: Text('${widget.badgeCount}'), child: widget.child),
        ),
      ),
    };
  }
}

/// Renders a badge scaled by its [listenable] animation (the pop effect).
class _BadgeScaleAnimation extends AnimatedWidget {
  const _BadgeScaleAnimation({required super.listenable, required this.label, this.child});

  final String label;
  final Widget? child;

  Animation<double> get _scale => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: _scale.value,
      child: Badge(label: Text(label), child: child),
    );
  }
}

/// Renders a badge translated horizontally by its [listenable] animation
/// (the shake effect).
class _BadgeShakeAnimation extends AnimatedWidget {
  const _BadgeShakeAnimation({required super.listenable, required this.label, this.child});

  final String label;
  final Widget? child;

  Animation<double> get _dx => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(_dx.value, 0),
      child: Badge(label: Text(label), child: child),
    );
  }
}