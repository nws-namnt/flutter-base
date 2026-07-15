import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_base/utils/extensions/widget_extension.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:gap/gap.dart';

import '../../common/app_enums.dart' show NotifyType;

/// Extension helpers for deriving Material 3 styling from a [BuildContext].
extension ContextExtension on BuildContext {
  /// Shorthand for `Directionality.of(this)`.
  ///
  /// Usage: read this instead of looking up [Directionality] manually when
  /// a widget needs to know text/layout direction (LTR vs RTL).
  ///
  /// Example:
  /// ```dart
  /// final dir = context.directionality;
  /// ```
  TextDirection get directionality => Directionality.of(this);

  /// Shorthand for `MediaQuery.of(this).orientation`.
  ///
  /// Usage: prefer [isLandscape] / [isPortrait] when you only need a
  /// boolean check; use this getter when the actual [Orientation] value is
  /// needed (e.g. in a `switch`).
  ///
  /// Example:
  /// ```dart
  /// final orientation = context.orientation;
  /// ```
  Orientation get orientation => MediaQuery.of(this).orientation;

  /// Shorthand for `MediaQuery.of(this).size`.
  ///
  /// Usage: read this for the current screen/viewport size instead of
  /// calling `MediaQuery.of(context).size` directly.
  ///
  /// Example:
  /// ```dart
  /// final screenWidth = context.size.width;
  /// ```
  ///
  /// Note: rebuilds whatever widget reads it whenever the [MediaQuery]
  /// size changes (rotation, window resize) — same caveat as calling
  /// `MediaQuery.of` directly.
  Size get size => MediaQuery.of(this).size;

  /// Shorthand for `Theme.of(this).brightness`.
  ///
  /// Usage: prefer [isDarkMode] for a plain boolean check; use this getter
  /// when the actual [Brightness] value is needed.
  ///
  /// Example:
  /// ```dart
  /// final brightness = context.brightness;
  /// ```
  Brightness get brightness => Theme.of(this).brightness;

  /// Shorthand for `Theme.of(this)`.
  ///
  /// Usage: read this instead of calling `Theme.of(context)` at every call
  /// site that needs the current [ThemeData].
  ///
  /// Example:
  /// ```dart
  /// final theme = context.theme;
  /// ```
  ThemeData get theme => Theme.of(this);

  /// Shorthand for `theme.colorScheme` (`Theme.of(this).colorScheme`).
  ///
  /// Usage: use this instead of hardcoding colors in widgets — per this
  /// project's theming convention, colors should always come from
  /// [ColorScheme] rather than literal [Color] values.
  ///
  /// Example:
  /// ```dart
  /// Container(color: context.colorScheme.primaryContainer);
  /// ```
  ColorScheme get colorScheme => theme.colorScheme;

  /// Shorthand for `theme.textTheme` (`Theme.of(this).textTheme`).
  ///
  /// Usage: read this for M3 text styles (`bodyMedium`, `titleLarge`, ...)
  /// instead of hardcoding [TextStyle]s.
  ///
  /// Example:
  /// ```dart
  /// Text('Hello', style: context.textTheme.bodyMedium);
  /// ```
  TextTheme get textTheme => theme.textTheme;

  /// `true` when the current [ThemeData.brightness] is [Brightness.dark].
  ///
  /// Usage: use for simple light/dark branching in `build` methods.
  ///
  /// Example:
  /// ```dart
  /// final icon = context.isDarkMode ? Icons.dark_mode : Icons.light_mode;
  /// ```
  bool get isDarkMode => brightness == .dark;

  /// `true` when the device/window is currently in [Orientation.landscape].
  ///
  /// Usage: use for simple orientation branching in `build` methods; use
  /// [orientation] directly when a `switch` over both values reads better.
  ///
  /// Example:
  /// ```dart
  /// final crossAxisCount = context.isLandscape ? 4 : 2;
  /// ```
  bool get isLandscape => orientation == .landscape;

  /// `true` when the device/window is currently in [Orientation.portrait].
  ///
  /// Usage: use for simple orientation branching in `build` methods; use
  /// [orientation] directly when a `switch` over both values reads better.
  ///
  /// Example:
  /// ```dart
  /// if (context.isPortrait) return const _PortraitLayout();
  /// ```
  bool get isPortrait => orientation == .portrait;

  /// Builds a [MarkdownStyleSheet] derived from the current M3 [ColorScheme]
  /// and [TextTheme].
  ///
  /// Usage: call this inside a widget's `build` method (not cached in
  /// `initState`) so the returned style stays in sync with light/dark theme
  /// changes.
  ///
  /// Example:
  /// ```dart
  /// Markdown(data: content, styleSheet: context.m3MarkdownStyle);
  /// ```
  MarkdownStyleSheet get m3MarkdownStyle {
    final scheme = Theme.of(this).colorScheme;
    final text = Theme.of(this).textTheme;

    final body = text.bodyMedium?.copyWith(color: scheme.onSurface);
    final muted = text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant);

    return MarkdownStyleSheet(
      // ── Body ────────────────────────────────────────────────────────────────
      p: body,
      pPadding: const EdgeInsets.only(bottom: 8),

      // ── Headings ─────────────────────────────────────────────────────────────
      h1: text.headlineMedium?.copyWith(color: scheme.onSurface),
      h1Padding: const EdgeInsets.only(top: 8, bottom: 12),
      h2: text.titleLarge?.copyWith(color: scheme.onSurface),
      h2Padding: const EdgeInsets.only(top: 8, bottom: 8),
      h3: text.titleMedium?.copyWith(
        color: scheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      h3Padding: const EdgeInsets.only(top: 4, bottom: 4),

      // ── Inline code ──────────────────────────────────────────────────────────
      code: text.bodySmall?.copyWith(
        color: scheme.primary,
        backgroundColor: scheme.surfaceContainerHighest,
        fontFamily: 'monospace',
      ),

      // ── Code block ───────────────────────────────────────────────────────────
      codeblockPadding: const EdgeInsets.all(12),
      codeblockDecoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.outlineVariant),
      ),

      // ── Blockquote ───────────────────────────────────────────────────────────
      blockquote: muted,
      blockquotePadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      blockquoteDecoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(4),
        border: Border(left: BorderSide(color: scheme.primary, width: 4)),
      ),

      // ── Horizontal rule ──────────────────────────────────────────────────────
      horizontalRuleDecoration: BoxDecoration(
        border: Border(top: BorderSide(color: scheme.outlineVariant, width: 1)),
      ),

      // ── Links ────────────────────────────────────────────────────────────────
      a: text.bodyMedium?.copyWith(
        color: scheme.primary,
        decoration: TextDecoration.underline,
        decorationColor: scheme.primary,
      ),

      // ── Lists ────────────────────────────────────────────────────────────────
      listBullet: body,
      listIndent: 20,

      // ── Table ────────────────────────────────────────────────────────────────
      tableHead: text.bodyMedium?.copyWith(
        color: scheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      tableBody: body,
      tableBorder: TableBorder.all(color: scheme.outlineVariant),
      tableHeadAlign: TextAlign.left,
      tableCellsPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      tableColumnWidth: const FlexColumnWidth(),

      // ── Emphasis / Strong ────────────────────────────────────────────────────
      em: body?.copyWith(fontStyle: FontStyle.italic),
      strong: body?.copyWith(fontWeight: FontWeight.w700),

      // ── Scaffold background ──────────────────────────────────────────────────
      // Makes the Markdown widget's own background transparent so Scaffold's
      // surface color shows through correctly.
      blockSpacing: 8,
    );
  }
}

/// Adds imperative, [BuildContext]-driven notification helpers:
/// [showNotify] (Flushbar-based toast), [showSnackBar] / [hideSnackBar]
/// (Material [SnackBar]), and [showM3Banner] / [hideM3Banner] (Material
/// [MaterialBanner]).
///
/// Unlike [showToast] (which is context-free and uses the platform toast API),
/// everything in this extension renders through the widget tree and
/// therefore needs a mounted [BuildContext] — every method here is a no-op
/// when [mounted] is `false`.
///
/// Typical usage:
/// ```dart
/// context.showNotify(type: NotifyType.success, messageText: 'Saved!');
/// context.showSnackBar(message: 'Upload failed', type: NotifyType.error);
/// ```
extension NotifyExtension on BuildContext {
  /// Shows a [Flushbar] notification anchored to this [BuildContext].
  ///
  /// [type] controls the default icon, background colour, title, and message
  /// text — all of which can be individually overridden via the corresponding
  /// parameters.
  ///
  /// Key parameters:
  ///
  /// - [type] — semantic category; defaults to [NotifyType.info].
  /// - [messageText] — plain-text body (uses [type]'s default when omitted).
  /// - [titleText] — plain-text heading (uses [type]'s default when omitted).
  /// - [message] / [title] — custom [Widget] overrides for body and heading.
  /// - [duration] — auto-dismiss delay; defaults to 2 000 ms.
  /// - [flushbarPosition] — [FlushbarPosition.BOTTOM] by default.
  /// - [isDismissible] — whether the user can swipe to dismiss; `true` by default.
  ///
  /// Example:
  /// ```dart
  /// context.showNotify(type: NotifyType.success, messageText: 'Saved!');
  /// ```
  ///
  /// Returns the [Future] from [Flushbar.show], which completes when the bar
  /// is fully dismissed.
  ///
  /// Note: unlike [showSnackBar] / [showM3Banner], this does not assert or
  /// require [messageText]/[message] — [type] alone already supplies a
  /// default title/message, so calling it with no arguments still shows a
  /// generic info bar. Does nothing if this [BuildContext] is no longer
  /// [mounted].
  Future<void> showNotify({
    final NotifyType type = NotifyType.info,

    final Widget? icon,
    final double? maxWidth,
    final Color? backgroundColor,
    final Duration? duration = const Duration(milliseconds: 2000),
    final List<BoxShadow>? boxShadows,
    final Gradient? backgroundGradient,

    final OnTap? onTap,

    final Widget? title,
    final Color? titleColor,
    final double? titleSize,
    final String? titleText,

    final Widget? message,
    final Color? messageColor,
    final double? messageSize,
    final String? messageText,

    final bool safeArea = true,
    final bool shouldIconPulse = true,
    final bool isDismissible = true,
    final bool showProgressIndicator = false,
    final bool blockBackgroundInteraction = false,

    final FlushbarDismissDirection dismissDirection =
        FlushbarDismissDirection.VERTICAL,
    final FlushbarPosition flushbarPosition = FlushbarPosition.BOTTOM,
    final FlushbarStyle flushbarStyle = FlushbarStyle.FLOATING,
    final TextDirection textDirection = TextDirection.ltr,

    final EdgeInsets margin = const EdgeInsets.all(0.0),
    final EdgeInsets padding = const EdgeInsets.all(16),

    final BorderRadius? borderRadius,
    final Color? borderColor,
    final double borderWidth = 1.0,

    final Curve forwardAnimationCurve = Curves.easeOutCirc,
    final Curve reverseAnimationCurve = Curves.easeOutCirc,
    final Duration animationDuration = const Duration(seconds: 1),

    final Color? leftBarIndicatorColor,
    final Widget? mainButton,
    final AnimationController? progressIndicatorController,
    final Color? progressIndicatorBackgroundColor,
    final Animation<Color>? progressIndicatorValueColor,
    final double positionOffset = 0.0,
    final double barBlur = 0.0,
    final double? routeBlur,
    final Color? routeColor,
    final Form? userInputForm,
    final Offset? endOffset,
  }) {
    if (!mounted) return Future<void>.value();

    return Flushbar(
      icon: icon ?? Icon(type.icon),
      maxWidth: maxWidth,
      backgroundColor: backgroundColor ?? (type.bgColor),
      duration: duration,
      boxShadows: boxShadows,
      backgroundGradient: backgroundGradient,

      onTap: onTap,

      title: titleText ?? (type.title),
      titleColor: titleColor,
      titleSize: titleSize,
      titleText: title,

      message: messageText ?? (type.message),
      messageColor: messageColor,
      messageSize: messageSize,
      messageText: message,

      safeArea: safeArea,
      shouldIconPulse: shouldIconPulse,
      isDismissible: isDismissible,
      showProgressIndicator: showProgressIndicator,
      blockBackgroundInteraction: blockBackgroundInteraction,

      dismissDirection: dismissDirection,
      flushbarPosition: flushbarPosition,
      flushbarStyle: flushbarStyle,
      textDirection: textDirection,

      margin: margin,
      padding: padding,

      borderRadius: borderRadius,
      borderColor: borderColor,
      borderWidth: borderWidth,

      forwardAnimationCurve: forwardAnimationCurve,
      reverseAnimationCurve: reverseAnimationCurve,
      animationDuration: animationDuration,

      leftBarIndicatorColor: leftBarIndicatorColor,
      mainButton: mainButton,
      progressIndicatorController: progressIndicatorController,
      progressIndicatorBackgroundColor: progressIndicatorBackgroundColor,
      progressIndicatorValueColor: progressIndicatorValueColor,
      positionOffset: positionOffset,
      barBlur: barBlur,
      routeBlur: routeBlur,
      routeColor: routeColor,
      userInputForm: userInputForm,
      endOffset: endOffset,
    ).show(this);
  }

  /// Shows a Material [SnackBar] anchored to this [BuildContext], with
  /// [type]-driven default icon/colors and an optional action button.
  ///
  /// Any snack bar currently visible on this [BuildContext]'s
  /// [ScaffoldMessenger] is hidden first (via
  /// [ScaffoldMessengerState.hideCurrentSnackBar]), so repeated calls replace
  /// rather than queue up behind one another.
  ///
  /// Provide **either** [content] (a fully custom widget) **or** [message]
  /// (plain text rendered with a [type]-derived icon) — passing neither
  /// trips an assertion in debug mode and silently shows a blank body in
  /// release mode.
  ///
  /// Key parameters:
  ///
  /// - [type] — semantic category; defaults to [NotifyType.info]. Drives
  ///   the default icon, text color, and background when [content] /
  ///   [bgColor] are omitted.
  /// - [content] — custom widget override; when provided, [message] is
  ///   ignored entirely.
  /// - [message] — plain-text body used to build the default [content].
  /// - [onAction] / [actionLabel] — convenience for building a
  ///   [SnackBarAction] without constructing one manually; ignored when
  ///   [action] is supplied directly.
  /// - [duration] — visible duration before auto-dismiss; defaults to
  ///   2500ms.
  /// - [persist] — when `true`, the snack bar stays visible until dismissed
  ///   instead of timing out. If omitted, defaults to `true` whenever an
  ///   [action] is present.
  ///
  /// The remaining parameters ([elevation], [margin], [padding], [width],
  /// [shape], [hitTestBehavior], [behavior], [actionOverflowThreshold],
  /// [showCloseIcon], [closeIconColor], [animation], [onVisible],
  /// [dismissDirection], [clipBehavior]) map 1:1 to [SnackBar]'s constructor
  /// — see there for full documentation.
  ///
  /// Does nothing if this [BuildContext] is no longer [mounted].
  ///
  /// Example:
  /// ```dart
  /// context.showSnackBar(message: 'Saved!', type: NotifyType.success);
  /// context.showSnackBar(
  ///   message: 'Upload failed',
  ///   type: NotifyType.error,
  ///   onAction: () => retryUpload(),
  ///   actionLabel: 'Retry',
  /// );
  /// ```
  void showSnackBar({
    Widget? content,
    String? message,
    Color? bgColor,
    double? elevation,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    double? width,
    ShapeBorder? shape,
    HitTestBehavior? hitTestBehavior,
    SnackBarBehavior? behavior,
    SnackBarAction? action,
    double? actionOverflowThreshold,
    bool? showCloseIcon,
    Color? closeIconColor,
    Duration duration = const Duration(milliseconds: 2500),
    bool? persist,
    Animation<double>? animation,
    VoidCallback? onVisible,
    DismissDirection? dismissDirection,
    Clip clipBehavior = Clip.hardEdge,
    NotifyType type = NotifyType.info,
    VoidCallback? onAction,
    String actionLabel = 'Label',
  }) {
    if (!mounted) return;

    assert(elevation == null || elevation >= 0.0);
    assert(
      width == null || margin == null,
      'Width and margin can not be used together',
    );
    assert(
      actionOverflowThreshold == null ||
          (actionOverflowThreshold >= 0 && actionOverflowThreshold <= 1),
      'Action overflow threshold must be between 0 and 1 inclusive',
    );
    assert(
      content != null || message != null,
      'Either content or message must be provided',
    );

    // Falls back to an empty body (rather than a null-check crash) if a
    // release build ever hits the "neither content nor message" case that
    // the assert above only catches in debug mode.
    final snackBar = SnackBar(
      content:
          content ??
          (message != null
              ? Row(
                  children: [
                    Icon(type.icon, color: type.color),
                    const Gap(10),
                    Text(
                      message,
                      style: TextStyle(
                        color: type.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ).expanded,
                  ],
                )
              : const SizedBox.shrink()),
      backgroundColor: bgColor ?? type.bgColor,
      elevation: elevation,
      margin: margin,
      padding:
          padding ??
          const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
      width: width,
      shape: shape,
      hitTestBehavior: hitTestBehavior,
      behavior: behavior,
      action:
          action ??
          (onAction != null
              ? SnackBarAction(
                  label: actionLabel,
                  onPressed: () => onAction.call(),
                  textColor: type.color,
                )
              : null),
      actionOverflowThreshold: actionOverflowThreshold,
      showCloseIcon: showCloseIcon,
      closeIconColor: closeIconColor ?? type.color,
      duration: duration,
      persist: persist ?? action != null,
      animation: animation,
      onVisible: onVisible,
      dismissDirection: dismissDirection,
      clipBehavior: clipBehavior,
    );

    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  /// Hides the currently visible [SnackBar] on this [BuildContext]'s
  /// [ScaffoldMessenger] — whether it was shown via [showSnackBar] or
  /// directly through [ScaffoldMessengerState.showSnackBar].
  ///
  /// Usage: call when navigating away from a screen or on an explicit
  /// "dismiss" action, so a lingering snack bar doesn't outlive its context.
  ///
  /// Example:
  /// ```dart
  /// context.hideSnackBar();
  /// ```
  ///
  /// Note: does nothing if this [BuildContext] is no longer [mounted].
  void hideSnackBar() {
    if (!mounted) return;
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
  }

  /// Shows a Material 3 [MaterialBanner] anchored to this [BuildContext]'s
  /// [ScaffoldMessenger], with [type]-driven default icon/colors.
  ///
  /// Unlike [showSnackBar]'s transient toast, a [MaterialBanner] is meant
  /// for persistent, non-urgent messages that stay on screen until the user
  /// resolves them via [actions] — e.g. "Your session will expire soon"
  /// with a "Stay signed in" button.
  ///
  /// Any banner currently visible on this [BuildContext]'s
  /// [ScaffoldMessenger] is hidden first (via
  /// [ScaffoldMessengerState.hideCurrentMaterialBanner]) — same as
  /// [showSnackBar] — so repeated calls replace rather than queue up behind
  /// one another. [ScaffoldMessengerState.hideCurrentMaterialBanner] is a
  /// documented no-op when nothing is currently shown, so there's no need to
  /// check for a visible banner before calling it.
  ///
  /// Provide **either** [content] (a fully custom widget) **or** [message]
  /// (plain text rendered with a [type]-derived icon) — passing neither
  /// trips an assertion in debug mode and silently shows a blank body in
  /// release mode.
  ///
  /// Key parameters:
  ///
  /// - [type] — semantic category; defaults to [NotifyType.info]. Drives the
  ///   default icon, text color, and background when [content] /
  ///   [backgroundColor] are omitted.
  /// - [content] — custom widget override; when provided, [message] is
  ///   ignored entirely.
  /// - [message] — plain-text body used to build the default [content].
  /// - [actions] — required. Material Banners don't auto-dismiss, so this
  ///   must give the user a way to resolve/close the banner.
  ///
  /// The remaining parameters ([contentTextStyle], [elevation], [leading],
  /// [surfaceTintColor], [shadowColor], [dividerColor], [padding], [margin],
  /// [leadingPadding], [forceActionsBelow], [overflowAlignment], [animation],
  /// [onVisible], [minActionBarHeight]) map 1:1 to [MaterialBanner]'s
  /// constructor — see there for full documentation.
  ///
  /// Does nothing if this [BuildContext] is no longer [mounted].
  ///
  /// Example:
  /// ```dart
  /// context.showM3Banner(
  ///   message: 'Your session will expire soon.',
  ///   type: NotifyType.warning,
  ///   actions: [
  ///     TextButton(
  ///       onPressed: staySignedIn,
  ///       child: const Text('Stay signed in'),
  ///     ),
  ///   ],
  /// );
  /// ```
  void showM3Banner({
    Widget? content,
    String? message,
    TextStyle? contentTextStyle,
    required List<Widget> actions,
    double? elevation,
    Widget? leading,
    Color? backgroundColor,
    Color? surfaceTintColor,
    Color? shadowColor,
    Color? dividerColor,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? leadingPadding,
    bool forceActionsBelow = false,
    OverflowBarAlignment overflowAlignment = OverflowBarAlignment.end,
    Animation<double>? animation,
    VoidCallback? onVisible,
    double minActionBarHeight = 52.0,
    NotifyType type = NotifyType.info,
  }) {
    if (!mounted) return;

    assert(elevation == null || elevation >= 0.0);

    assert(
      content != null || message != null,
      'Either content or message must be provided',
    );
    final m3Banner = MaterialBanner(
      content:
          content ??
          (message != null
              ? Row(
                  children: [
                    Icon(type.icon, color: type.color),
                    const Gap(10),
                    Text(
                      message,
                      style: TextStyle(
                        color: type.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ).expanded,
                  ],
                )
              : const SizedBox.shrink()),
      contentTextStyle: contentTextStyle,
      actions: actions,
      elevation: elevation,
      leading: leading,
      backgroundColor: backgroundColor ?? type.bgColor,
      surfaceTintColor: surfaceTintColor,
      shadowColor: shadowColor,
      dividerColor: dividerColor,
      padding: padding,
      margin: margin,
      leadingPadding: leadingPadding,
      forceActionsBelow: forceActionsBelow,
      overflowAlignment: overflowAlignment,
      animation: animation,
      onVisible: onVisible,
      minActionBarHeight: minActionBarHeight,
    );

    ScaffoldMessenger.of(this)
      ..hideCurrentMaterialBanner()
      ..showMaterialBanner(m3Banner);
  }

  /// Hides the currently visible [MaterialBanner] on this [BuildContext]'s
  /// [ScaffoldMessenger] — whether it was shown via [showM3Banner] or
  /// directly through [ScaffoldMessengerState.showMaterialBanner].
  ///
  /// Usage: call once the user resolves whatever [showM3Banner] was
  /// prompting them about, e.g. after a "Stay signed in" button handler
  /// finishes running.
  ///
  /// Example:
  /// ```dart
  /// context.hideM3Banner();
  /// ```
  ///
  /// Note: does nothing if this [BuildContext] is no longer [mounted].
  void hideM3Banner() {
    if (!mounted) return;
    ScaffoldMessenger.of(this).hideCurrentMaterialBanner();
  }
}
