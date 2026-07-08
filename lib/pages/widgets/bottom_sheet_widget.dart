import 'package:flutter/material.dart';

const double _kDefaultScrollControlDisabledMaxHeightRatio = 9.0 / 16.0;

enum _SheetType { unableScroll, scroll }

/// A [Page] that presents its content as a modal bottom sheet, for use as a
/// GoRoute's `pageBuilder` return value.
///
/// Two named constructors cover the two [showModalBottomSheet] usage modes:
/// [BottomSheetWidget.scroll] for a [DraggableScrollableSheet]-backed sheet,
/// and [BottomSheetWidget.unScroll] for a plain, non-draggable sheet built
/// directly from [builder].
class BottomSheetWidget<T> extends Page<T> {
  /// Builds the sheet's content.
  ///
  /// For [BottomSheetWidget.scroll], use [scrollableBuilder] instead — this
  /// is only invoked directly by [BottomSheetWidget.unScroll].
  final WidgetBuilder builder;

  /// Forwarded to [ModalBottomSheetRoute.capturedThemes].
  final CapturedThemes? capturedThemes;

  /// Forwarded to [ModalBottomSheetRoute.barrierLabel].
  final String? barrierLabel;

  /// Forwarded to [ModalBottomSheetRoute.barrierOnTapHint].
  final String? barrierOnTapHint;

  /// Forwarded to [ModalBottomSheetRoute.backgroundColor]. Defaults to
  /// [Colors.white] if omitted.
  final Color? backgroundColor;

  /// Forwarded to [ModalBottomSheetRoute.elevation].
  final double? elevation;

  /// Forwarded to [ModalBottomSheetRoute.shape].
  final ShapeBorder? shape;

  /// Forwarded to [ModalBottomSheetRoute.clipBehavior].
  final Clip? clipBehavior;

  /// Forwarded to [ModalBottomSheetRoute.constraints].
  final BoxConstraints? constraints;

  /// Forwarded to [ModalBottomSheetRoute.modalBarrierColor]. Defaults to
  /// black at 50% opacity if omitted.
  final Color? modalBarrierColor;

  /// Forwarded to [ModalBottomSheetRoute.isDismissible].
  final bool isDismissible;

  /// Forwarded to [ModalBottomSheetRoute.enableDrag].
  final bool enableDrag;

  /// Forwarded to [ModalBottomSheetRoute.showDragHandle].
  final bool? showDragHandle;

  /// Forwarded to [ModalBottomSheetRoute.isScrollControlled].
  final bool isScrollControlled;

  /// Forwarded to [ModalBottomSheetRoute.scrollControlDisabledMaxHeightRatio].
  final double scrollControlDisabledMaxHeightRatio;

  /// Forwarded to [ModalBottomSheetRoute.transitionAnimationController].
  final AnimationController? transitionAnimationController;

  /// Forwarded to [ModalBottomSheetRoute.anchorPoint].
  final Offset? anchorPoint;

  /// Forwarded to [ModalBottomSheetRoute.useSafeArea].
  final bool useSafeArea;

  /// Forwarded to [ModalBottomSheetRoute.sheetAnimationStyle].
  final AnimationStyle? sheetAnimationStyle;

  // For DraggableScrollableSheet
  /// Builds the sheet's content for [BottomSheetWidget.scroll], wrapped in a
  /// [DraggableScrollableSheet]. Required for that constructor.
  final ScrollableWidgetBuilder? scrollableBuilder;

  /// Forwarded to [DraggableScrollableSheet.initialChildSize].
  final double? initialChildSize;

  /// Forwarded to [DraggableScrollableSheet.maxChildSize].
  final double? maxChildSize;

  /// Forwarded to [DraggableScrollableSheet.minChildSize].
  final double? minChildSize;

  /// Forwarded to [DraggableScrollableSheet.expand].
  final bool? expand;

  /// Forwarded to [DraggableScrollableSheet.snap].
  final bool? snap;

  /// Forwarded to [DraggableScrollableSheet.snapSizes].
  final List<double>? snapSizes;

  /// Forwarded to [DraggableScrollableSheet.snapAnimationDuration].
  final Duration? snapAnimationDuration;

  /// Forwarded to [DraggableScrollableSheet.controller].
  final DraggableScrollableController? controller;

  /// Forwarded to [DraggableScrollableSheet.shouldCloseOnMinExtent].
  final bool? shouldCloseOnMinExtent;

  /// Creates a [BottomSheetWidget] whose content is a draggable,
  /// [DraggableScrollableSheet]-backed sheet built via [scrollableBuilder].
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

  /// Creates a [BottomSheetWidget] whose content is a plain, non-draggable
  /// sheet built directly from [builder].
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
