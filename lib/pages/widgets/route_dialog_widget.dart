import 'package:flutter/material.dart';
import 'package:flutter_base/base.dart';

class RouteDialogWidget<T> extends Page<T> {
  const RouteDialogWidget({
    required this.builder,
    this.transitionType = DialogTransitionType.fadeScale,
    this.reverseTransitionType,
    this.curve = Curves.easeOut,
    this.reverseCurve = Curves.easeIn,
    this.barrierDismissible = true,
    this.barrierColor = const Color(0x80000000),
    this.barrierLabel,
    this.transitionDuration = const Duration(milliseconds: 250),
    this.reverseTransitionDuration,
    this.insetPadding,
    this.dialogRadius,
    this.anchorPoint,
    this.requestFocus,
    this.traversalEdgeBehavior,
    this.directionalTraversalEdgeBehavior,
    this.fullscreenDialog = false,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  final WidgetBuilder builder;
  final DialogTransitionType transitionType;
  final DialogTransitionType? reverseTransitionType;
  final Curve curve;
  final Curve reverseCurve;
  final bool barrierDismissible;
  final Color barrierColor;
  final String? barrierLabel;
  final Duration transitionDuration;
  final Duration? reverseTransitionDuration;
  final EdgeInsets? insetPadding;
  final double? dialogRadius;
  final Offset? anchorPoint;
  final bool? requestFocus;
  final TraversalEdgeBehavior? traversalEdgeBehavior;
  final TraversalEdgeBehavior? directionalTraversalEdgeBehavior;
  final bool fullscreenDialog;

  @override
  Route<T> createRoute(BuildContext context) => TransitionDialog(
    transitionType: transitionType,
    reverseTransitionType: reverseTransitionType,
    curve: curve,
    reverseCurve: reverseCurve,
    settings: this,
    anchorPoint: anchorPoint,
    requestFocus: requestFocus,
    traversalEdgeBehavior: traversalEdgeBehavior,
    directionalTraversalEdgeBehavior: directionalTraversalEdgeBehavior,
    fullscreenDialog: fullscreenDialog,
    pageBuilder: (context, ani, secondaryAni) => Dialog(
      insetPadding: insetPadding,
      backgroundColor: AppColors.pureWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(dialogRadius ?? 12.0),
      ),
      child: builder(context),
    ),
    transitionDuration: transitionDuration,
    reverseTransitionDuration: reverseTransitionDuration,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    barrierLabel: barrierLabel ?? MaterialLocalizations.of(context).modalBarrierDismissLabel,
  );
}
