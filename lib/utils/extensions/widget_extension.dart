import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

extension WidgetExtension on Widget {
  Widget get center => Center(child: this);

  Widget get expanded => Expanded(child: this);

  Widget get flexible => Flexible(child: this);

  Widget get equalExpand => Expanded(
    flex: 1,
    child: this,
  );

  Widget tightExpand(int flex) => Expanded(
    flex: flex,
    child: this,
  );

  Widget looseExpand(int flex) => Flexible(
    flex: flex,
    child: this,
  );

  Widget inkWell({
    required GestureTapCallback onTap,
    Color? color,
  }) => InkWell(
    onTap: onTap,
    highlightColor: color,
    splashColor: color,
    child: this,
  );

  Widget gesture({
    required GestureTapCallback onTap,
  }) => GestureDetector(
    onTap: onTap,
    child: this,
  );

  Widget get posFill => Positioned.fill(child: this);

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

  Widget aspect({required double ratio}) => AspectRatio(aspectRatio: ratio, child: this);

  Widget gap(double mainAxisGapExtent) => Gap(mainAxisGapExtent);

  Widget pad({
    required double left,
    required double top,
    required double right,
    required double bottom,
  }) => Padding(padding: EdgeInsets.fromLTRB(left, top, right, bottom), child: this);

  Widget symPad({
    double horizontal = .0,
    double vertical = .0,
  }) => Padding(padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical), child: this);
}

