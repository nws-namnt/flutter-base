import 'package:flutter/material.dart';

/// Fluent shorthand for wrapping a [Widget] in common layout widgets, e.g.
/// `myWidget.center` instead of `Center(child: myWidget)`.
extension WidgetExtension on Widget {
  /// Wraps this widget in a [Center].
  ///
  /// Usage: use as a terse alternative to `Center(child: myWidget)` when
  /// centering a single widget.
  ///
  /// Example:
  /// ```dart
  /// const Text('Hi').center
  /// ```
  Widget get center => Center(child: this);

  /// Wraps this widget in an [Expanded] with the default `flex: 1`.
  ///
  /// Usage: use inside a [Row]/[Column] to have this widget fill the
  /// remaining space.
  ///
  /// Example:
  /// ```dart
  /// Row(children: [const Icon(Icons.star), title.expanded])
  /// ```
  Widget get expanded => Expanded(child: this);

  /// Wraps this widget in a [Flexible] with the default `flex: 1`.
  ///
  /// Usage: use inside a [Row]/[Column] when this widget should be allowed
  /// to shrink to fit, unlike [expanded]/[Expanded] which forces it to fill
  /// the available space.
  ///
  /// Example:
  /// ```dart
  /// Row(children: [label.flexible, const Icon(Icons.chevron_right)])
  /// ```
  Widget get flexible => Flexible(child: this);

  /// Wraps this widget in an [Expanded] with `flex: 1`.
  ///
  /// Semantically identical to [expanded]; use alongside [tightExpand] when
  /// several siblings should split space equally.
  ///
  /// Usage: reach for this name (over [expanded]) when the call site is
  /// specifically about splitting space *equally* among several siblings —
  /// it documents intent even though the behavior is the same.
  ///
  /// Example:
  /// ```dart
  /// Row(children: [left.equalExpand, right.equalExpand])
  /// ```
  Widget get equalExpand => Expanded(
    flex: 1,
    child: this,
  );

  /// Wraps this widget in an [Expanded] with the given [flex] factor.
  ///
  /// Usage: use when siblings in a [Row]/[Column] should split space
  /// unevenly, e.g. a 2:1 ratio between two panels.
  ///
  /// Example:
  /// ```dart
  /// Row(children: [left.tightExpand(2), right.tightExpand(1)])
  /// ```
  Widget tightExpand(int flex) => Expanded(
    flex: flex,
    child: this,
  );

  /// Wraps this widget in a [Flexible] with the given [flex] factor.
  ///
  /// Usage: like [tightExpand], but the widget is allowed to shrink below
  /// its [flex] share instead of being forced to fill it.
  ///
  /// Example:
  /// ```dart
  /// Row(children: [left.looseExpand(2), right.looseExpand(1)])
  /// ```
  Widget looseExpand(int flex) => Flexible(
    flex: flex,
    child: this,
  );

  /// Wraps this widget in an [InkWell] with the given [onTap] callback.
  ///
  /// [color] is used for both [InkWell.highlightColor] and
  /// [InkWell.splashColor] when provided.
  ///
  /// Usage: use to make any widget tappable with a Material ripple, without
  /// writing the [InkWell] boilerplate at the call site.
  ///
  /// Example:
  /// ```dart
  /// const Icon(Icons.favorite).inkWell(onTap: toggleFavorite)
  /// ```
  ///
  /// Note: [InkWell] needs an ancestor [Material] to render its ink
  /// effects — this extension does not add one, so make sure this widget
  /// sits inside a [Scaffold]/[Card]/other [Material] ancestor.
  Widget inkWell({
    required GestureTapCallback onTap,
    Color? color,
  }) => InkWell(
    onTap: onTap,
    highlightColor: color,
    splashColor: color,
    child: this,
  );

  /// Wraps this widget in a [GestureDetector] with the given [onTap] callback.
  ///
  /// Usage: use when you need a tap handler without a Material ripple
  /// effect; use [inkWell] instead when the ripple feedback is wanted.
  ///
  /// Example:
  /// ```dart
  /// avatar.gesture(onTap: openProfile)
  /// ```
  Widget gesture({
    required GestureTapCallback onTap,
  }) => GestureDetector(
    onTap: onTap,
    child: this,
  );

  /// Wraps this widget in a [Positioned.fill].
  ///
  /// Usage: use inside a [Stack] to make this widget fill the stack's
  /// bounds — e.g. a background image or overlay.
  ///
  /// Example:
  /// ```dart
  /// Stack(children: [background.posFill, const _Content()])
  /// ```
  ///
  /// Note: only valid as a direct child of a [Stack] — using it elsewhere
  /// throws, the same as [Positioned] itself.
  Widget get posFill => Positioned.fill(child: this);

  /// Wraps this widget in a [Positioned] with the given edge offsets.
  ///
  /// Usage: use inside a [Stack] to place this widget at a specific offset
  /// from one or more edges, instead of writing `Positioned(...)` inline.
  ///
  /// Example:
  /// ```dart
  /// Stack(children: [badge.pos(top: 8, right: 8), const _Content()])
  /// ```
  ///
  /// Note: only valid as a direct child of a [Stack], same as [Positioned].
  Widget pos({
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) => Positioned(
    left: left,
    top: top,
    right: right,
    bottom: bottom,
    child: this,
  );

  /// Wraps this widget in an [AspectRatio] with the given [ratio].
  ///
  /// Usage: use to constrain this widget to a fixed width/height ratio,
  /// e.g. keeping an image or video at 16:9.
  ///
  /// Example:
  /// ```dart
  /// videoPlayer.aspect(ratio: 16 / 9)
  /// ```
  Widget aspect({required double ratio}) => AspectRatio(aspectRatio: ratio, child: this);

  /// Wraps this widget in a [Padding] with independently specified edge insets.
  ///
  /// Usage: use when each edge needs a different inset; use [symPad] when
  /// horizontal/vertical insets are each uniform, or [padAll] when all four
  /// edges share one value.
  ///
  /// Example:
  /// ```dart
  /// content.pad(left: 16, top: 8, right: 16, bottom: 24)
  /// ```
  Widget pad({
    required double left,
    required double top,
    required double right,
    required double bottom,
  }) => Padding(padding: .fromLTRB(left, top, right, bottom), child: this);

  /// Wraps this widget in a [Padding] with symmetric [horizontal] and
  /// [vertical] insets.
  ///
  /// Usage: the common case — use whenever horizontal and vertical padding
  /// each need to be uniform but may differ from each other. Both default
  /// to `0`, so passing only one side is fine.
  ///
  /// Example:
  /// ```dart
  /// title.symPad(horizontal: 16, vertical: 8)
  /// ```
  Widget symPad({
    double horizontal = .0,
    double vertical = .0,
  }) => Padding(padding: .symmetric(horizontal: horizontal, vertical: vertical), child: this);

  /// Wraps this widget in a [Padding] with only horizontal insets applied
  /// (defaults to `0`).
  ///
  /// Usage: use as shorthand for `symPad(horizontal: value)` when no
  /// vertical padding is needed.
  ///
  /// Example:
  /// ```dart
  /// listTile.padX(16)
  /// ```
  Widget padX([double horizontal = .0]) => Padding(padding: .symmetric(horizontal: horizontal), child: this);

  /// Wraps this widget in a [Padding] with only vertical insets applied
  /// (defaults to `0`).
  ///
  /// Usage: use as shorthand for `symPad(vertical: value)` when no
  /// horizontal padding is needed.
  ///
  /// Example:
  /// ```dart
  /// divider.padY(8)
  /// ```
  Widget padY([double vertical = .0]) => Padding(padding: .symmetric(vertical: vertical), child: this);

  /// Wraps this widget in a [Padding] with the same inset on all four edges.
  ///
  /// Usage: use when every edge needs the same amount of padding; use
  /// [symPad]/[pad] when edges differ.
  ///
  /// Example:
  /// ```dart
  /// card.padAll(12)
  /// ```
  Widget padAll(double all) => Padding(padding: .all(all), child: this);
}
