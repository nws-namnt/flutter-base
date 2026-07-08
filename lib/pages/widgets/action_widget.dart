import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../utils/extensions/string_extension.dart';

/// Selects which design language [ActionWidget] renders with.
enum ActionStyle {
  /// Renders with a Material button ([ActionMaterial] picks the variant).
  material,

  /// Renders with a Cupertino button ([ActionCupertino] picks the variant).
  cupertino,
}

/// Material button variants supported by [ActionWidget] when
/// `style == ActionStyle.material`.
/// Out of scope: [ToggleButtons], [SegmentedButton], [FloatingActionButton], [DropdownButton]
/// [PopupMenuButton], [MenuItemButton], [SubmenuButton], [BackButton], [CloseButton]
enum ActionMaterial {
  /// [ElevatedButton] — filled, elevated on press.
  elevation,

  /// [TextButton] — no outline or fill.
  text,

  /// [OutlinedButton] — outlined border, no fill.
  outline,

  /// [FilledButton] — filled, no elevation. See also [filledTonal].
  filled,

  /// [FilledButton.tonal] — filled with a secondary (lower-emphasis) color.
  filledTonal,

  /// [IconButton] — icon only, no [ActionWidget.label] text is rendered.
  /// [ActionWidget.iconVariant] picks the standard/filled/filledTonal/outlined
  /// look.
  icon,
}

/// [IconButton] variants supported by [ActionWidget] when
/// `materialType == ActionMaterial.icon`. Mirrors Material 3's icon button
/// styles — has no effect for any other [ActionMaterial] value.
enum ActionIconVariant {
  /// Plain [IconButton].
  standard,

  /// [IconButton.filled] — highest emphasis, for actions like toggling a
  /// microphone or camera.
  filled,

  /// [IconButton.filledTonal] — middle ground between filled and outlined.
  filledTonal,

  /// [IconButton.outlined] — medium emphasis.
  outlined,
}

/// Cupertino button variants supported by [ActionWidget] when
/// `style == ActionStyle.cupertino`.
enum ActionCupertino {
  /// Plain [CupertinoButton] — no background.
  standard,

  /// [CupertinoButton.tinted] — translucent background derived from the
  /// theme's primary color (or [ActionWidget.cupertinoFillColor] if set).
  tinted,

  /// [CupertinoButton.filled], or a custom-filled [CupertinoButton] if
  /// [ActionWidget.cupertinoFillColor] is set.
  fill,
}

/// A single button widget that adapts to either Material or Cupertino,
/// covering [ElevatedButton], [TextButton], [OutlinedButton], [FilledButton],
/// [IconButton], and [CupertinoButton] behind one consistent API.
///
/// Pick the design language with [style], then the concrete variant with
/// [materialType] or [cupertinoType]. [label] is required for every variant
/// except `style: material, materialType: icon`, where only [icon] is shown,
/// or whenever [child] is provided (Material elevation/text/outline/filled
/// variants only).
class ActionWidget extends StatelessWidget {
  // Commons
  /// Design language to render with. Defaults to [ActionStyle.material].
  final ActionStyle style;

  /// Material button variant, used when [style] is [ActionStyle.material].
  final ActionMaterial materialType;

  /// [IconButton] shape variant, used when [materialType] is
  /// [ActionMaterial.icon]. Has no effect otherwise.
  final ActionIconVariant iconVariant;

  /// Cupertino button variant, used when [style] is [ActionStyle.cupertino].
  final ActionCupertino cupertinoType;

  /// Button text. Required for every variant except
  /// `style: material, materialType: icon` and whenever [child] is provided
  /// (see the class-level asserts).
  final String? label;

  /// Custom content, replacing [label]/[icon] entirely.
  ///
  /// Only supported by the Material elevation/text/outline/filled/filledTonal
  /// variants — not [ActionMaterial.icon] ([IconButton] has no `child`
  /// parameter, use [icon] instead) and not Cupertino. When set, the plain
  /// button constructor is used instead of `.icon(...)`, so [iconAlignment]
  /// has no effect.
  final Widget? child;

  /// {@macro flutter.widgets.Focus.focusNode}
  final FocusNode? focusNode;

  /// {@macro flutter.widgets.Focus.autofocus}
  final bool autofocus;

  /// Content clip behavior. Not supported by [ActionMaterial.icon]
  /// ([IconButton] has no `clipBehavior` parameter) — leave at the default
  /// there.
  final Clip clipBehavior;

  /// Programmatic control over the button's [WidgetState]s (pressed,
  /// hovered, focused, ...). Supported by every Material variant, including
  /// [ActionMaterial.icon] ([IconButton] has its own `statesController`) —
  /// [CupertinoButton] has no equivalent and is out of scope for this field.
  final WidgetStatesController? statesController;

  // Actions
  /// Called when the button is tapped. If null, the button is disabled.
  final VoidCallback? onAction;

  /// Called when the button is long-pressed.
  final VoidCallback? onLongPress;

  /// Called when a pointer enters/exits the button's hover region.
  ///
  /// Not supported by [CupertinoButton] — see the class-level assert.
  final ValueChanged<bool>? onHover;

  /// Called when the button gains/loses focus. Not supported by
  /// [ActionMaterial.icon] ([IconButton] has no `onFocusChange` parameter).
  final ValueChanged<bool>? onFocusChange;

  // Icon Configs
  /// Icon to show alongside (or instead of) [label].
  ///
  /// Required when `materialType == ActionMaterial.icon`. For the other
  /// Material variants, a non-null value renders an `.icon(...)` button
  /// constructor instead of the plain one; leave null for a text-only button.
  final IconData? icon;

  /// Icon size. Defaults to [IconThemeData.size] (24.0) when null.
  final double? iconSize;

  /// Icon color. Maps to [IconButton.color] for `materialType: icon`.
  final Color? iconColor;

  /// Where the icon sits relative to [label] (start or end).
  final IconAlignment iconAlignment;

  // Styles
  /// Explicit [ButtonStyle], overriding the one built from the other style
  /// fields via `_MaterialAction._styleFromType`.
  final ButtonStyle? btnStyle;

  /// Text/icon color. Ignored for `materialType: icon` when [iconColor] is
  /// also set — see that field.
  final Color? foregroundColor;

  /// Background fill color.
  final Color? backgroundColor;

  /// Elevation. Ignored by [ActionMaterial.text] and [ActionMaterial.outline]
  /// (both are zero-elevation by design).
  final double? elevation;

  /// Text style applied to [label].
  final TextStyle? textStyle;

  /// Internal padding.
  final EdgeInsetsGeometry? padding;

  /// Alignment of the button's content. For Cupertino, defaults to
  /// [Alignment.center] when null.
  final AlignmentGeometry? alignment;

  /// Message shown on long-press/hover and used for accessibility.
  ///
  /// For `materialType: icon`, this is forwarded natively to
  /// [IconButton.tooltip] instead of being wrapped by [_Wrap]'s [Tooltip],
  /// since [IconButton] already handles tooltip display itself. Every other
  /// variant gets the [_Wrap] treatment.
  final String? tooltip;

  /// Accessibility label, read instead of [label] by screen readers.
  final String? semanticsLabel;

  /// How compact the button's layout is. Not supported by [CupertinoButton].
  final VisualDensity? visualDensity;

  /// Corner radius. Maps to [CupertinoButton.borderRadius] for Cupertino
  /// variants, or a [RoundedRectangleBorder] shape for Material variants.
  final BorderRadius? radius;

  /// Border side. Material variants only — [CupertinoButton] has no
  /// equivalent.
  final BorderSide? side;

  // Icon button only
  /// Icon shown instead of [icon] when [isSelected] is true
  /// (`ActionMaterial.icon` only).
  final Widget? selectedIcon;

  /// Toggle state for `ActionMaterial.icon` — see [IconButton.isSelected].
  final bool isSelected;

  /// Whether detected gestures should provide acoustic/haptic feedback.
  /// `ActionMaterial.icon` only — see [IconButton.enableFeedback].
  final bool? enableFeedback;

  /// Size constraints for the button. `ActionMaterial.icon` only — see
  /// [IconButton.constraints].
  final BoxConstraints? constraints;

  /// Splash radius. `ActionMaterial.icon` only — see [IconButton.splashRadius].
  /// Ignored under Material 3.
  final double? splashRadius;

  /// Color while hovered. `ActionMaterial.icon` only — see
  /// [IconButton.hoverColor].
  final Color? hoverColor;

  /// Color while pressed (Material 2 only). `ActionMaterial.icon` only —
  /// see [IconButton.highlightColor].
  final Color? highlightColor;

  /// Splash color (Material 2 only). `ActionMaterial.icon` only — see
  /// [IconButton.splashColor].
  final Color? splashColor;

  // Icon button + Cupertino
  /// Color while focused. Used by `ActionMaterial.icon`
  /// ([IconButton.focusColor]) and Cupertino ([CupertinoButton.focusColor]).
  final Color? focusColor;

  /// Mouse cursor while hovering. Used by `ActionMaterial.icon`
  /// ([IconButton.mouseCursor]) and Cupertino ([CupertinoButton.mouseCursor]).
  final MouseCursor? mouseCursor;

  /// Color while disabled. Used by `ActionMaterial.icon`
  /// ([IconButton.disabledColor]) and Cupertino
  /// ([CupertinoButton.disabledColor]) — for Cupertino, leaving this null
  /// keeps that variant's own default (`quaternarySystemFill` for
  /// [ActionCupertino.standard], `tertiarySystemFill` otherwise).
  final Color? disabledColor;

  // Cupertino only
  /// Opacity while pressed. Cupertino only — see
  /// [CupertinoButton.pressedOpacity]. Defaults to `0.4` when null, matching
  /// [CupertinoButton]'s own default.
  final double? pressedOpacity;

  /// Minimum tappable size. Cupertino only — see
  /// [CupertinoButton.minimumSize].
  final Size? minimumSize;

  // Cupertino button filled/tinted only
  /// Custom fill/tint color for `style: cupertino` with `cupertinoType`
  /// [ActionCupertino.fill] or [ActionCupertino.tinted]. If null, falls back
  /// to that variant's own default color.
  final Color? cupertinoFillColor;

  /// Creates an [ActionWidget].
  const ActionWidget({
    super.key,
    // Commons
    this.style = ActionStyle.material,
    this.materialType = ActionMaterial.elevation,
    this.iconVariant = ActionIconVariant.standard,
    this.cupertinoType = ActionCupertino.standard,
    this.label,
    this.child,
    this.focusNode,
    this.autofocus = false,
    this.clipBehavior = Clip.none,
    this.statesController,
    // Actions
    this.onAction,
    this.onLongPress,
    this.onHover,
    this.onFocusChange,
    // Icon configs
    this.icon,
    this.iconSize, // Default icon size from IconThemeData.size is 24.0
    this.iconColor,
    this.iconAlignment = IconAlignment.start,
    // Styles
    this.btnStyle,
    this.foregroundColor,
    this.backgroundColor,
    this.elevation,
    this.textStyle,
    this.padding,
    this.alignment,
    this.tooltip,
    this.semanticsLabel,
    this.visualDensity,
    this.radius,
    this.side,
    // Icon button only
    this.selectedIcon,
    this.isSelected = false,
    this.enableFeedback,
    this.constraints,
    this.splashRadius,
    this.hoverColor,
    this.highlightColor,
    this.splashColor,
    // Icon button + Cupertino
    this.focusColor,
    this.mouseCursor,
    this.disabledColor,
    // Cupertino only
    this.pressedOpacity,
    this.minimumSize,
    // Cupertino button filled/tinted only
    this.cupertinoFillColor,
  }) : assert(
         materialType != ActionMaterial.icon || icon != null,
         'ActionWidget(material + icon): icon must not be null.',
       ),
       assert(
         label != null ||
             child != null ||
             (style == ActionStyle.material &&
                 materialType == ActionMaterial.icon),
         'ActionWidget: label is required unless child is provided, or style is material '
         'and materialType is icon.',
       ),
       assert(
         child == null || style == ActionStyle.material,
         'ActionWidget(child): only supported when style is material — CupertinoButton has no '
         'child override, its content is always the label Text.',
       ),
       assert(
         child == null || materialType != ActionMaterial.icon,
         'ActionWidget(child): not supported by ActionMaterial.icon — IconButton has no child '
         'parameter, use icon instead.',
       ),
       assert(
         materialType != ActionMaterial.icon || clipBehavior == Clip.none,
         'ActionWidget(material + icon): clipBehavior is not supported by IconButton and would '
         'silently be ignored — leave it at the default (Clip.none).',
       ),
       assert(
         materialType != ActionMaterial.icon || onFocusChange == null,
         'ActionWidget(material + icon): onFocusChange is not supported by IconButton and would '
         'silently be ignored.',
       ),
       assert(
         style != ActionStyle.cupertino || onHover == null,
         'ActionWidget(cupertino): onHover is not supported by CupertinoButton and would be '
         'silently ignored — use onLongPress or onAction instead.',
       ),
       assert(
         iconVariant == ActionIconVariant.standard ||
             materialType == ActionMaterial.icon,
         'ActionWidget(iconVariant): only used when materialType is icon; it has no effect '
         'otherwise.',
       );
  // Note: no assert is needed to validate `style` itself — build() below
  // switches on the ActionStyle enum, so the compiler already rejects any
  // missing case if a new style is ever added.

  @override
  Widget build(BuildContext context) {
    // IconButton shows its own native tooltip — don't double-wrap with
    // _Wrap's Tooltip in that case.
    final bool nativeTooltip =
        style == ActionStyle.material && materialType == ActionMaterial.icon;
    return _Wrap(
      semanticsLabel: semanticsLabel,
      tooltip: nativeTooltip ? null : tooltip,
      child: switch (style) {
        ActionStyle.material => _MaterialAction(this),
        ActionStyle.cupertino => _CupertinoAction(this),
      },
    );
  }
}

/// Wraps [child] with [Semantics]/[Tooltip] when [semanticsLabel]/[tooltip]
/// are provided, applying them the same way regardless of which concrete
/// button [ActionWidget] renders.
class _Wrap extends StatelessWidget {
  final Widget child;
  final String? semanticsLabel;
  final String? tooltip;

  const _Wrap({required this.child, this.semanticsLabel, this.tooltip});

  @override
  Widget build(BuildContext context) {
    final bool hasSemantics = semanticsLabel.isValidate;
    final bool hasTooltip = tooltip.isValidate;

    // No wrap
    if (!hasSemantics && !hasTooltip) return child;
    Widget wrapped = child;
    if (hasSemantics) {
      wrapped = Semantics(
        label: semanticsLabel,
        hint: hasTooltip ? tooltip : null,
        button: true,
        child: wrapped,
      );
    }

    if (hasTooltip) {
      wrapped = Tooltip(message: tooltip, child: wrapped);
    }

    return wrapped;
  }
}

/// Renders the Material variant of an [ActionWidget], selected by
/// [ActionWidget.materialType].
///
/// Split out from [ActionWidget] into its own widget for readability and
/// DevTools clarity (shows up as its own node in the widget tree) — this by
/// itself does not reduce rebuild cost, since [ActionWidget] still rebuilds
/// this widget with fresh data on every build regardless of whether the
/// logic lives in a getter or a separate class.
///
/// [ElevatedButton], [TextButton], [OutlinedButton], and [FilledButton] all
/// expose an `.icon(...)` constructor whose `icon` parameter is optional —
/// passing `icon: null` renders exactly like the plain constructor. So a
/// single `.icon(...)` call covers both the icon and no-icon case for each
/// of those, instead of branching on `icon != null` per variant.
class _MaterialAction extends StatelessWidget {
  const _MaterialAction(this.data);

  /// The [ActionWidget] instance this widget renders. Reads straight from
  /// [data]'s fields instead of re-declaring ~30 constructor parameters —
  /// this widget is only ever built from within [ActionWidget.build] and
  /// isn't meant to be reused independently.
  final ActionWidget data;

  @override
  Widget build(BuildContext context) {
    final style = data.btnStyle ?? _styleFromType;
    final iconWidget = data.icon != null
        ? Icon(data.icon, size: data.iconSize, color: data.iconColor)
        : null;

    switch (data.materialType) {
      case ActionMaterial.elevation:
        return data.child != null
            ? ElevatedButton(
                focusNode: data.focusNode,
                autofocus: data.autofocus,
                clipBehavior: data.clipBehavior,
                onPressed: data.onAction,
                onLongPress: data.onLongPress,
                onHover: data.onHover,
                onFocusChange: data.onFocusChange,
                style: style,
                statesController: data.statesController,
                child: data.child,
              )
            : ElevatedButton.icon(
                focusNode: data.focusNode,
                autofocus: data.autofocus,
                clipBehavior: data.clipBehavior,
                onPressed: data.onAction,
                onLongPress: data.onLongPress,
                onHover: data.onHover,
                onFocusChange: data.onFocusChange,
                style: style,
                statesController: data.statesController,
                icon: iconWidget,
                label: Text(data.label!),
                iconAlignment: data.iconAlignment,
              );
      case ActionMaterial.text:
        return data.child != null
            ? TextButton(
                focusNode: data.focusNode,
                autofocus: data.autofocus,
                clipBehavior: data.clipBehavior,
                onPressed: data.onAction,
                onLongPress: data.onLongPress,
                onHover: data.onHover,
                onFocusChange: data.onFocusChange,
                style: style,
                statesController: data.statesController,
                // TextButton's child is non-nullable (unlike Elevated/OutlinedButton);
                // data.child != null is already checked above.
                child: data.child!,
              )
            : TextButton.icon(
                focusNode: data.focusNode,
                autofocus: data.autofocus,
                clipBehavior: data.clipBehavior,
                onPressed: data.onAction,
                onLongPress: data.onLongPress,
                onHover: data.onHover,
                onFocusChange: data.onFocusChange,
                style: style,
                statesController: data.statesController,
                icon: iconWidget,
                label: Text(data.label!),
                iconAlignment: data.iconAlignment,
              );
      case ActionMaterial.outline:
        return data.child != null
            ? OutlinedButton(
                focusNode: data.focusNode,
                autofocus: data.autofocus,
                clipBehavior: data.clipBehavior,
                onPressed: data.onAction,
                onLongPress: data.onLongPress,
                onHover: data.onHover,
                onFocusChange: data.onFocusChange,
                style: style,
                statesController: data.statesController,
                child: data.child,
              )
            : OutlinedButton.icon(
                focusNode: data.focusNode,
                autofocus: data.autofocus,
                clipBehavior: data.clipBehavior,
                onPressed: data.onAction,
                onLongPress: data.onLongPress,
                onHover: data.onHover,
                onFocusChange: data.onFocusChange,
                style: style,
                statesController: data.statesController,
                icon: iconWidget,
                label: Text(data.label!),
                iconAlignment: data.iconAlignment,
              );
      case ActionMaterial.filled:
        return data.child != null
            ? FilledButton(
                focusNode: data.focusNode,
                autofocus: data.autofocus,
                clipBehavior: data.clipBehavior,
                onPressed: data.onAction,
                onLongPress: data.onLongPress,
                onHover: data.onHover,
                onFocusChange: data.onFocusChange,
                style: style,
                statesController: data.statesController,
                child: data.child,
              )
            : FilledButton.icon(
                focusNode: data.focusNode,
                autofocus: data.autofocus,
                clipBehavior: data.clipBehavior,
                onPressed: data.onAction,
                onLongPress: data.onLongPress,
                onHover: data.onHover,
                onFocusChange: data.onFocusChange,
                style: style,
                statesController: data.statesController,
                icon: iconWidget,
                label: Text(data.label!),
                iconAlignment: data.iconAlignment,
              );
      case ActionMaterial.filledTonal:
        return data.child != null
            ? FilledButton.tonal(
                focusNode: data.focusNode,
                autofocus: data.autofocus,
                clipBehavior: data.clipBehavior,
                onPressed: data.onAction,
                onLongPress: data.onLongPress,
                onHover: data.onHover,
                onFocusChange: data.onFocusChange,
                style: style,
                statesController: data.statesController,
                child: data.child,
              )
            : FilledButton.tonalIcon(
                focusNode: data.focusNode,
                autofocus: data.autofocus,
                clipBehavior: data.clipBehavior,
                onPressed: data.onAction,
                onLongPress: data.onLongPress,
                onHover: data.onHover,
                onFocusChange: data.onFocusChange,
                style: style,
                statesController: data.statesController,
                icon: iconWidget,
                label: Text(data.label!),
                iconAlignment: data.iconAlignment,
              );
      case ActionMaterial.icon:
        // icon != null is guaranteed by ActionWidget's constructor assert.
        // clipBehavior/onFocusChange are intentionally not forwarded —
        // IconButton has no such parameters.
        return switch (data.iconVariant) {
          ActionIconVariant.standard => IconButton(
            iconSize: data.iconSize,
            visualDensity: data.visualDensity,
            padding: data.padding,
            alignment: data.alignment,
            splashRadius: data.splashRadius,
            color: data.iconColor,
            focusColor: data.focusColor,
            hoverColor: data.hoverColor,
            highlightColor: data.highlightColor,
            splashColor: data.splashColor,
            disabledColor: data.disabledColor,
            onPressed: data.onAction,
            onHover: data.onHover,
            onLongPress: data.onLongPress,
            mouseCursor: data.mouseCursor,
            focusNode: data.focusNode,
            autofocus: data.autofocus,
            tooltip: data.tooltip,
            enableFeedback: data.enableFeedback,
            constraints: data.constraints,
            style: style,
            isSelected: data.isSelected,
            selectedIcon: data.selectedIcon,
            statesController: data.statesController,
            icon: iconWidget!,
          ),
          ActionIconVariant.filled => IconButton.filled(
            iconSize: data.iconSize,
            visualDensity: data.visualDensity,
            padding: data.padding,
            alignment: data.alignment,
            splashRadius: data.splashRadius,
            color: data.iconColor,
            focusColor: data.focusColor,
            hoverColor: data.hoverColor,
            highlightColor: data.highlightColor,
            splashColor: data.splashColor,
            disabledColor: data.disabledColor,
            onPressed: data.onAction,
            onHover: data.onHover,
            onLongPress: data.onLongPress,
            mouseCursor: data.mouseCursor,
            focusNode: data.focusNode,
            autofocus: data.autofocus,
            tooltip: data.tooltip,
            enableFeedback: data.enableFeedback,
            constraints: data.constraints,
            style: style,
            isSelected: data.isSelected,
            selectedIcon: data.selectedIcon,
            statesController: data.statesController,
            icon: iconWidget!,
          ),
          ActionIconVariant.filledTonal => IconButton.filledTonal(
            iconSize: data.iconSize,
            visualDensity: data.visualDensity,
            padding: data.padding,
            alignment: data.alignment,
            splashRadius: data.splashRadius,
            color: data.iconColor,
            focusColor: data.focusColor,
            hoverColor: data.hoverColor,
            highlightColor: data.highlightColor,
            splashColor: data.splashColor,
            disabledColor: data.disabledColor,
            onPressed: data.onAction,
            onHover: data.onHover,
            onLongPress: data.onLongPress,
            mouseCursor: data.mouseCursor,
            focusNode: data.focusNode,
            autofocus: data.autofocus,
            tooltip: data.tooltip,
            enableFeedback: data.enableFeedback,
            constraints: data.constraints,
            style: style,
            isSelected: data.isSelected,
            selectedIcon: data.selectedIcon,
            statesController: data.statesController,
            icon: iconWidget!,
          ),
          ActionIconVariant.outlined => IconButton.outlined(
            iconSize: data.iconSize,
            visualDensity: data.visualDensity,
            padding: data.padding,
            alignment: data.alignment,
            splashRadius: data.splashRadius,
            color: data.iconColor,
            focusColor: data.focusColor,
            hoverColor: data.hoverColor,
            highlightColor: data.highlightColor,
            splashColor: data.splashColor,
            disabledColor: data.disabledColor,
            onPressed: data.onAction,
            onHover: data.onHover,
            onLongPress: data.onLongPress,
            mouseCursor: data.mouseCursor,
            focusNode: data.focusNode,
            autofocus: data.autofocus,
            tooltip: data.tooltip,
            enableFeedback: data.enableFeedback,
            constraints: data.constraints,
            style: style,
            isSelected: data.isSelected,
            selectedIcon: data.selectedIcon,
            statesController: data.statesController,
            icon: iconWidget!,
          ),
        };
    }
  }

  /// Builds the [ButtonStyle] for [ActionWidget.materialType] from the
  /// individual style fields (foregroundColor, backgroundColor, radius,
  /// ...), used unless [ActionWidget.btnStyle] is explicitly provided.
  ButtonStyle get _styleFromType => switch (data.materialType) {
    ActionMaterial.elevation => ElevatedButton.styleFrom(
      alignment: data.alignment,
      foregroundColor: data.foregroundColor,
      backgroundColor: data.backgroundColor,
      elevation: data.elevation,
      textStyle: data.textStyle,
      padding: data.padding,
      visualDensity: data.visualDensity,
      shape: data.radius != null
          ? RoundedRectangleBorder(borderRadius: data.radius!)
          : null,
      side: data.side,
    ),
    ActionMaterial.text => TextButton.styleFrom(
      alignment: data.alignment,
      foregroundColor: data.foregroundColor,
      backgroundColor: data.backgroundColor,
      // elevation: elevation,  // A text button is a label child displayed on a (zero elevation) Material widget.
      textStyle: data.textStyle,
      padding: data.padding,
      visualDensity: data.visualDensity,
      shape: data.radius != null
          ? RoundedRectangleBorder(borderRadius: data.radius!)
          : null,
      side: data.side,
    ),
    ActionMaterial.outline => OutlinedButton.styleFrom(
      alignment: data.alignment,
      foregroundColor: data.foregroundColor,
      backgroundColor: data.backgroundColor,
      // elevation: elevation, // An outlined button is a label child displayed on a (zero elevation) Material widget.
      textStyle: data.textStyle,
      padding: data.padding,
      visualDensity: data.visualDensity,
      shape: data.radius != null
          ? RoundedRectangleBorder(borderRadius: data.radius!)
          : null,
      side: data.side,
    ),
    ActionMaterial.filled || ActionMaterial.filledTonal => FilledButton.styleFrom(
      alignment: data.alignment,
      foregroundColor: data.foregroundColor,
      backgroundColor: data.backgroundColor,
      elevation: data.elevation,
      textStyle: data.textStyle,
      padding: data.padding,
      visualDensity: data.visualDensity,
      shape: data.radius != null
          ? RoundedRectangleBorder(borderRadius: data.radius!)
          : null,
      side: data.side,
    ),
    ActionMaterial.icon => IconButton.styleFrom(
      alignment: data.alignment,
      // foregroundColor: foregroundColor, // Do not set foregroundColor if iconColor is set already via style and vice versa
      backgroundColor: data.backgroundColor,
      elevation: data.elevation,
      padding: data.padding,
      visualDensity: data.visualDensity,
      shape: data.radius != null
          ? RoundedRectangleBorder(borderRadius: data.radius!)
          : null,
      side: data.side,
    ),
  };
}

/// Renders the Cupertino variant of an [ActionWidget], selected by
/// [ActionWidget.cupertinoType]. Split out purely for readability/DevTools
/// clarity, same rationale as [_MaterialAction].
class _CupertinoAction extends StatelessWidget {
  const _CupertinoAction(this.data);

  /// The [ActionWidget] instance this widget renders — see [_MaterialAction.data].
  final ActionWidget data;

  /// Matches [CupertinoButton]'s own per-variant default disabled color
  /// (plain uses `quaternarySystemFill`, tinted/filled use
  /// `tertiarySystemFill`), so leaving [ActionWidget.disabledColor] unset
  /// doesn't change the built-in look.
  Color get _defaultDisabledColor => data.cupertinoType == ActionCupertino.standard
      ? CupertinoColors.quaternarySystemFill
      : CupertinoColors.tertiarySystemFill;

  @override
  Widget build(BuildContext context) => switch (data.cupertinoType) {
    ActionCupertino.standard => CupertinoButton(
      onPressed: data.onAction,
      onLongPress: data.onLongPress,
      padding: data.padding,
      borderRadius: data.radius,
      alignment: data.alignment ?? Alignment.center,
      disabledColor: data.disabledColor ?? _defaultDisabledColor,
      focusColor: data.focusColor,
      focusNode: data.focusNode,
      onFocusChange: data.onFocusChange,
      autofocus: data.autofocus,
      mouseCursor: data.mouseCursor,
      pressedOpacity: data.pressedOpacity ?? 0.4,
      minimumSize: data.minimumSize,
      child: Text(data.label!),
    ),
    ActionCupertino.tinted => CupertinoButton.tinted(
      onPressed: data.onAction,
      onLongPress: data.onLongPress,
      padding: data.padding,
      borderRadius: data.radius,
      color: data.cupertinoFillColor,
      alignment: data.alignment ?? Alignment.center,
      disabledColor: data.disabledColor ?? _defaultDisabledColor,
      focusColor: data.focusColor,
      focusNode: data.focusNode,
      onFocusChange: data.onFocusChange,
      autofocus: data.autofocus,
      mouseCursor: data.mouseCursor,
      pressedOpacity: data.pressedOpacity ?? 0.4,
      minimumSize: data.minimumSize,
      child: Text(data.label!),
    ),
    ActionCupertino.fill =>
      data.cupertinoFillColor != null
          ? CupertinoButton(
              onPressed: data.onAction,
              onLongPress: data.onLongPress,
              padding: data.padding,
              borderRadius: data.radius,
              color: data.cupertinoFillColor,
              alignment: data.alignment ?? Alignment.center,
              disabledColor: data.disabledColor ?? _defaultDisabledColor,
              focusColor: data.focusColor,
              focusNode: data.focusNode,
              onFocusChange: data.onFocusChange,
              autofocus: data.autofocus,
              mouseCursor: data.mouseCursor,
              pressedOpacity: data.pressedOpacity ?? 0.4,
              minimumSize: data.minimumSize,
              child: Text(data.label!),
            )
          : CupertinoButton.filled(
              onPressed: data.onAction,
              onLongPress: data.onLongPress,
              padding: data.padding,
              borderRadius: data.radius,
              alignment: data.alignment ?? Alignment.center,
              disabledColor: data.disabledColor ?? _defaultDisabledColor,
              focusColor: data.focusColor,
              focusNode: data.focusNode,
              onFocusChange: data.onFocusChange,
              autofocus: data.autofocus,
              mouseCursor: data.mouseCursor,
              pressedOpacity: data.pressedOpacity ?? 0.4,
              minimumSize: data.minimumSize,
              child: Text(data.label!),
            ),
  };
}
