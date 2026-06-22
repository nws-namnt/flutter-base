import 'package:flutter/material.dart';

const double _kDefaultScrollControlDisabledMaxHeightRatio = 9.0 / 16.0;

enum _SheetType { unableScroll, scroll }

class BottomSheetWidget<T> extends Page<T> {
  final WidgetBuilder builder;
  final CapturedThemes? capturedThemes;
  final String? barrierLabel;
  final String? barrierOnTapHint;
  final Color? backgroundColor;
  final double? elevation;
  final ShapeBorder? shape;
  final Clip? clipBehavior;
  final BoxConstraints? constraints;
  final Color? modalBarrierColor;
  final bool isDismissible;
  final bool enableDrag;
  final bool? showDragHandle;
  final bool isScrollControlled;
  final double scrollControlDisabledMaxHeightRatio;
  final AnimationController? transitionAnimationController;
  final Offset? anchorPoint;
  final bool useSafeArea;
  final AnimationStyle? sheetAnimationStyle;
  // For DraggableScrollableSheet
  final ScrollableWidgetBuilder? scrollableBuilder;
  final double? initialChildSize;
  final double? maxChildSize;
  final double? minChildSize;
  final bool? expand;
  final bool? snap;
  final List<double>? snapSizes;
  final Duration? snapAnimationDuration;
  final DraggableScrollableController? controller;
  final bool? shouldCloseOnMinExtent;

  const BottomSheetWidget.scroll({
    required this.builder,
    this.capturedThemes,
    this.barrierLabel,
    this.barrierOnTapHint,
    this.backgroundColor,
    this.elevation,
    this.shape,
    this.clipBehavior,
    this.constraints,
    this.modalBarrierColor,
    this.isDismissible = true,
    this.enableDrag = true,
    this.showDragHandle,
    this.isScrollControlled = true,
    this.scrollControlDisabledMaxHeightRatio = _kDefaultScrollControlDisabledMaxHeightRatio,
    this.transitionAnimationController,
    this.anchorPoint,
    this.useSafeArea = false,
    this.sheetAnimationStyle,
    this.scrollableBuilder,
    this.initialChildSize,
    this.maxChildSize,
    this.minChildSize,
    this.expand,
    this.snap,
    this.snapSizes,
    this.snapAnimationDuration,
    this.controller,
    this.shouldCloseOnMinExtent,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  })  : _sheetType = _SheetType.scroll,
        assert(scrollableBuilder != null, 'scrollableBuilder is required for BottomSheetWidget.scroll');

  const BottomSheetWidget.unScroll({
    required this.builder,
    this.capturedThemes,
    this.barrierLabel,
    this.barrierOnTapHint,
    this.backgroundColor,
    this.elevation,
    this.shape,
    this.clipBehavior,
    this.constraints,
    this.modalBarrierColor,
    this.isDismissible = true,
    this.enableDrag = true,
    this.showDragHandle,
    this.isScrollControlled = false,
    this.scrollControlDisabledMaxHeightRatio = _kDefaultScrollControlDisabledMaxHeightRatio,
    this.transitionAnimationController,
    this.anchorPoint,
    this.useSafeArea = false,
    this.sheetAnimationStyle,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  })  : _sheetType = _SheetType.unableScroll,
        scrollableBuilder = null,
        initialChildSize = null,
        maxChildSize = null,
        minChildSize = null,
        expand = null,
        snap = null,
        snapSizes = null,
        snapAnimationDuration = null,
        controller = null,
        shouldCloseOnMinExtent = null;

  final _SheetType _sheetType;

  @override
  Route<T> createRoute(BuildContext context) => ModalBottomSheetRoute<T>(
    builder: (context) => switch(_sheetType) {
      _SheetType.scroll => _ScrollBottomSheet(
        builder: scrollableBuilder!,
        initialChildSize: initialChildSize,
        maxChildSize: maxChildSize,
        minChildSize: minChildSize,
        expand: expand ?? false,
        snap: snap ?? true,
        snapSizes: snapSizes,
        snapAnimationDuration: snapAnimationDuration,
        controller: controller,
        shouldCloseOnMinExtent: shouldCloseOnMinExtent ?? false,
      ),
      _SheetType.unableScroll => builder(context),
    },
    capturedThemes: capturedThemes,
    barrierLabel: barrierLabel ?? '',
    barrierOnTapHint: barrierOnTapHint,
    backgroundColor: backgroundColor ?? Colors.white,
    elevation: elevation,
    shape: shape,
    clipBehavior: clipBehavior,
    constraints: constraints,
    modalBarrierColor: modalBarrierColor ?? Colors.black.withValues(alpha: 0.5),
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    showDragHandle: showDragHandle,
    isScrollControlled: isScrollControlled,
    scrollControlDisabledMaxHeightRatio: scrollControlDisabledMaxHeightRatio,
    settings: this,
    transitionAnimationController: transitionAnimationController,
    anchorPoint: anchorPoint,
    useSafeArea: useSafeArea,
    sheetAnimationStyle: sheetAnimationStyle,
  );
}

class _ScrollBottomSheet extends StatelessWidget {
  final ScrollableWidgetBuilder builder;
  final double? initialChildSize;
  final double? minChildSize;
  final double? maxChildSize;
  final bool expand;
  final bool snap;
  final List<double>? snapSizes;
  final Duration? snapAnimationDuration;
  final DraggableScrollableController? controller;
  final bool shouldCloseOnMinExtent;

  const _ScrollBottomSheet({
    required this.builder,
    this.initialChildSize,
    this.minChildSize,
    this.maxChildSize,
    required this.expand,
    required this.snap,
    this.snapSizes,
    this.snapAnimationDuration,
    this.controller,
    required this.shouldCloseOnMinExtent,
  })  : assert(minChildSize == null || minChildSize >= 0.0),
        assert(maxChildSize == null || maxChildSize <= 1.0),
        assert(minChildSize == null || initialChildSize == null || minChildSize <= initialChildSize),
        assert(initialChildSize == null || maxChildSize == null || initialChildSize <= maxChildSize),
        assert(snapAnimationDuration == null || snapAnimationDuration > Duration.zero);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      builder: builder,
      initialChildSize: initialChildSize ?? .5,
      maxChildSize: maxChildSize ?? .85,
      minChildSize: minChildSize ?? .25,
      expand: expand,
      snap: snap,
      snapSizes: snapSizes,
      snapAnimationDuration: snapAnimationDuration,
      controller: controller,
      shouldCloseOnMinExtent: shouldCloseOnMinExtent,
    );
  }
}
