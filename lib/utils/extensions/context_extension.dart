import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import '../../common/app_enums.dart' show AppNotifyType;

/// Builds a [MarkdownStyleSheet] derived from the current M3 [ColorScheme]
/// and [TextTheme]. Call inside [build] so it picks up light/dark changes.
extension ContextExtension on BuildContext {
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

/// Adds [showNotify] to [BuildContext] for imperative flushbar-based
/// notifications that require the widget tree.
///
/// Unlike [showToast] (which is context-free and uses the platform toast API),
/// this extension renders a fully customisable overlay widget via
/// `another_flushbar` and therefore needs a mounted [BuildContext].
///
/// Typical usage:
/// ```dart
/// context.showNotify(type: AppNotifyType.success, messageText: 'Saved!');
/// context.showNotify(type: AppNotifyType.error, messageText: 'Upload failed');
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
  /// - [type] — semantic category; defaults to [AppNotifyType.info].
  /// - [messageText] — plain-text body (uses [type]'s default when omitted).
  /// - [titleText] — plain-text heading (uses [type]'s default when omitted).
  /// - [message] / [title] — custom [Widget] overrides for body and heading.
  /// - [duration] — auto-dismiss delay; defaults to 2 000 ms.
  /// - [flushbarPosition] — [FlushbarPosition.BOTTOM] by default.
  /// - [isDismissible] — whether the user can swipe to dismiss; `true` by default.
  ///
  /// Returns the [Future] from [Flushbar.show], which completes when the bar
  /// is fully dismissed.
  Future<void> showNotify({
    final AppNotifyType type = AppNotifyType.info,

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
  }) => Flushbar(
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