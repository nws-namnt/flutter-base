import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

/// Plays the Material *container transform* transition pattern between a
/// closed and an open state.
///
/// The container transform pattern is designed for transitions between UI
/// elements that include a container, creating a visible connection between
/// the two. Typical use cases:
///
///  * A card expanding into a details page
///  * A list item expanding into a details page
///  * A FAB expanding into a details page
///  * A search bar expanding into an expanded search page
///
/// This is a thin, documented pass-through over [OpenContainer]: every
/// constructor parameter mirrors [OpenContainer]'s own, with the same
/// defaults, so refer to that class for the full behavior of each one.
///
/// `T` is the type of data returned when the container closes (via
/// [onClosed] and the open builder's close action) — use `void` or leave it
/// unspecified if no value needs to be returned.
///
/// See also:
///
///  * [OpenContainer], the underlying widget this wraps.
///  * https://m3.material.io/styles/motion/transitions/transition-patterns#container-transform
///    for the Material motion spec this pattern implements.
class OpenContainerWrapper<T extends Object?> extends StatelessWidget {
  /// Creates an [OpenContainerWrapper].
  const OpenContainerWrapper({
    super.key,
    required this.closedBuilder,
    required this.openBuilder,
    this.transitionType = ContainerTransitionType.fade,
    this.onClosed,
    this.tappable = true,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.closedColor = Colors.white,
    this.openColor = Colors.white,
    this.middleColor,
    this.closedElevation = 1.0,
    this.openElevation = 4.0,
    this.closedShape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(4.0)),
    ),
    this.openShape = const RoundedRectangleBorder(),
    this.closedShadows,
    this.openShadows,
    this.useRootNavigator = false,
    this.routeSettings,
    this.clipBehavior = Clip.antiAlias,
  });

  /// Builds the widget shown while the container is closed.
  ///
  /// The `action` callback passed to the builder opens the container — call
  /// it explicitly if [tappable] is `false`, or in addition to it otherwise
  /// (e.g. from a button nested inside the closed content).
  final CloseContainerBuilder closedBuilder;

  /// Builds the widget shown once the container has fully opened.
  ///
  /// The `action` callback passed to the builder closes the container and
  /// optionally passes a value of type [T] back to [onClosed] (e.g.
  /// `action(returnValue: result)`).
  final OpenContainerBuilder<T> openBuilder;

  /// The type of fade used between the closed and open content.
  ///
  /// Defaults to [ContainerTransitionType.fade].
  final ContainerTransitionType transitionType;

  /// Called once the container has fully closed again, with whatever value
  /// was passed to the open builder's close action (or `null` if none was
  /// passed / the route was popped via the system back gesture).
  final ClosedCallback<T?>? onClosed;

  /// Whether tapping anywhere on the closed container opens it.
  ///
  /// When `false`, the container can only be opened by calling the `action`
  /// callback passed to [closedBuilder].
  ///
  /// Defaults to `true`.
  final bool tappable;

  /// How long the open/close animation takes.
  ///
  /// Defaults to 300ms.
  final Duration transitionDuration;

  /// Background color while closed.
  ///
  /// Defaults to [Colors.white].
  final Color closedColor;

  /// Background color while open.
  ///
  /// Defaults to [Colors.white].
  final Color openColor;

  /// Background color midway through the transition, used only with
  /// [ContainerTransitionType.fadeThrough].
  ///
  /// Defaults to the ambient [ThemeData.canvasColor].
  final Color? middleColor;

  /// Elevation while closed.
  ///
  /// Ignored when [closedShadows] is set. Defaults to `1.0`.
  final double closedElevation;

  /// Elevation while open.
  ///
  /// Ignored when [openShadows] is set. Defaults to `4.0`.
  final double openElevation;

  /// Shape while closed.
  ///
  /// Defaults to a rounded rectangle with a 4.0 radius.
  final ShapeBorder closedShape;

  /// Shape while open.
  ///
  /// Defaults to a plain rectangle.
  final ShapeBorder openShape;

  /// Custom shadows while closed; overrides [closedElevation] when set.
  final List<BoxShadow>? closedShadows;

  /// Custom shadows while open; overrides [openElevation] when set.
  final List<BoxShadow>? openShadows;

  /// Whether the open route is pushed on the root [Navigator] (`true`) or
  /// the nearest enclosing one (`false`).
  ///
  /// Defaults to `false`.
  final bool useRootNavigator;

  /// Route settings applied to the pushed open route.
  final RouteSettings? routeSettings;

  /// Clip behavior of the closed container.
  ///
  /// Defaults to [Clip.antiAlias].
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    return OpenContainer<T>(
      transitionType: transitionType,
      closedColor: closedColor,
      openColor: openColor,
      middleColor: middleColor,
      closedElevation: closedElevation,
      openElevation: openElevation,
      closedShape: closedShape,
      openShape: openShape,
      closedShadows: closedShadows,
      openShadows: openShadows,
      onClosed: onClosed,
      tappable: tappable,
      transitionDuration: transitionDuration,
      useRootNavigator: useRootNavigator,
      routeSettings: routeSettings,
      clipBehavior: clipBehavior,
      closedBuilder: closedBuilder,
      openBuilder: openBuilder,
    );
  }
}
