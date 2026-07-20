import 'package:flutter/material.dart';
import 'package:flutter_base/base.dart';
import 'package:gap/gap.dart';

/// The inner content of a confirmation dialog, mirroring the layout of a
/// Material [AlertDialog] (title, message, and a cancel/confirm action row).
///
/// This widget intentionally does NOT wrap itself in a [Dialog]/[AlertDialog]:
/// it is meant to be passed as the `builder` of a [RouteDialogWidget] /
/// [TransitionDialog], which already provides the [Dialog] surface (background,
/// rounded shape, inset). Wrapping it again would nest one dialog surface inside
/// another and double the padding and shadow.
///
/// By default each button pops the enclosing route with a [bool] result via
/// [RouterExtension.backDialogWithResult] — `true` for confirm, `false` for
/// cancel — so callers can `await` the route result.
///
/// Register it as a route's `pageBuilder`, then push by name to read the
/// result:
///
/// ```dart
/// // In router_config.dart:
/// GoRoute(
///   path: Routers.confirm.routerPath,
///   pageBuilder: (context, state) => RouteDialogWidget<bool>(
///     builder: (_) => const ConfirmDialogWidget(
///       title: 'Logout',
///       message: 'Are you sure you want to sign out?',
///     ),
///   ),
/// );
///
/// // At the call site:
/// final confirmed = await context.pushNamed<bool>(Routers.confirm.routerName);
/// ```
///
/// Provide [onCancel] / [onConfirm] to override the default pop behaviour.
class ConfirmDialogWidget extends StatelessWidget {
  const ConfirmDialogWidget({
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.onConfirm,
    this.onCancel,
    super.key,
  });

  /// Heading text, rendered with [TextTheme.titleLarge].
  final String title;

  /// Body text, rendered with [TextTheme.bodyMedium].
  final String message;

  /// Caption of the confirm (primary) button.
  final String confirmLabel;

  /// Caption of the cancel (secondary) button.
  final String cancelLabel;

  /// Called when the confirm button is tapped. Defaults to popping the route
  /// with `true`.
  final VoidCallback? onConfirm;

  /// Called when the cancel button is tapped. Defaults to popping the route
  /// with `false`.
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    // Matches AlertDialog's default 24px content inset so the dialog looks
    // identical whether rendered here or via a real AlertDialog.
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(title, style: context.textTheme.titleLarge),
          const Gap(16),

          // Message
          Text(message, style: context.textTheme.bodyMedium),
          const Gap(24),

          // Actions
          OverflowBar(
            alignment: MainAxisAlignment.end,
            spacing: 8,
            overflowAlignment: OverflowBarAlignment.end,
            children: [
              TextButton(
                onPressed: onCancel ?? () => context.backDialogWithResult(false),
                child: Text(cancelLabel),
              ),
              FilledButton.tonal(
                onPressed: onConfirm ?? () => context.backDialogWithResult(true),
                child: Text(confirmLabel),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
