import 'package:flutter/material.dart';

/// Fluent shorthand for wrapping a [Widget] in common layout widgets, e.g.
/// `myWidget.center` instead of `Center(child: myWidget)`.
extension WidgetExtension on Widget {
  /// Wraps this widget in a [Center].
  Widget get center => Center(child: this);

  /// Wraps this widget in an [Expanded] with the default `flex: 1`.
  Widget get expanded => Expanded(child: this);

  /// Wraps this widget in a [Flexible] with the default `flex: 1`.
  Widget get flexible => Flexible(child: this);

  /// Wraps this widget in an [Expanded] with `flex: 1`.
  ///
  /// Semantically identical to [expanded]; use alongside [tightExpand] when
  /// several siblings should split space equally.
  Widget get equalExpand => Expanded(
    flex: 1,
    child: this,
  );

  /// Wraps this widget in an [Expanded] with the given [flex] factor.
  Widget tightExpand(int flex) => Expanded(
    flex: flex,
    child: this,
  );

  /// Wraps this widget in a [Flexible] with the given [flex] factor.
  Widget looseExpand(int flex) => Flexible(
    flex: flex,
    child: this,
  );

  /// Wraps this widget in an [InkWell] with the given [onTap] callback.
  ///
  /// [color] is used for both [InkWell.highlightColor] and
  /// [InkWell.splashColor] when provided.
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
  Widget gesture({
    required GestureTapCallback onTap,
  }) => GestureDetector(
    onTap: onTap,
    child: this,
  );

  /// Wraps this widget in a [Positioned.fill].
  Widget get posFill => Positioned.fill(child: this);

  /// Wraps this widget in a [Positioned] with the given edge offsets.
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
  Widget aspect({required double ratio}) => AspectRatio(aspectRatio: ratio, child: this);

  /// Wraps this widget in a [Padding] with independently specified edge insets.
  Widget pad({
    required double left,
    required double top,
    required double right,
    required double bottom,
  }) => Padding(padding: EdgeInsets.fromLTRB(left, top, right, bottom), child: this);

  /// Wraps this widget in a [Padding] with symmetric [horizontal] and
  /// [vertical] insets.
  Widget symPad({
    double horizontal = .0,
    double vertical = .0,
  }) => Padding(padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical), child: this);
}

