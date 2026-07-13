import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Inline replacement for Flutter's default red error screen.
///
/// Wired up via `ErrorWidget.builder` in `main()`. Flutter swaps in this
/// widget only for the subtree that failed to build (e.g. inside a
/// `ListTile`), not the whole screen, so it must stay compact and avoid
/// assuming a `Scaffold` ancestor.
///
/// - Debug/profile: shows the exception summary, message, the library that
///   threw it, and a collapsible stack trace — using the app's error color
///   roles ([ColorScheme.errorContainer] / [ColorScheme.onErrorContainer])
///   so it follows the active light/dark theme.
/// - Release: shows a minimal placeholder with no error internals, since
///   end users should never see stack traces.
///   Test: throw an exception to test (for example, throw Exception('test error widget') after build method);
class RenderErrorWidget extends StatelessWidget {
  /// Creates a [RenderErrorWidget] from the [FlutterErrorDetails] passed by
  /// `ErrorWidget.builder`.
  const RenderErrorWidget({required this.details, super.key});

  /// The error captured by the Flutter framework.
  final FlutterErrorDetails details;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (!kDebugMode) {
      // Release: no exception details leaked to end users.
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        alignment: Alignment.center,
        color: colorScheme.errorContainer,
        child: Icon(
          Icons.error_outline,
          color: colorScheme.onErrorContainer,
          size: 24,
        ),
      );
    }

    final textStyle = TextStyle(
      color: colorScheme.onErrorContainer,
      fontSize: 12,
    );
    final stack = details.stack?.toString();

    // ExpansionTile's header relies on InkWell, which needs a Material
    // ancestor to paint its splash. The background color must live on this
    // Material itself (not on a separate colored Container/ColoredBox in
    // between) — an opaque ColoredBox sitting between Material and the
    // InkWell would hide the splash entirely (Flutter asserts on this).
    return Material(
      color: colorScheme.errorContainer,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: colorScheme.onErrorContainer,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      details.exceptionAsString(),
                      style: textStyle.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              if (details.library != null) ...[
                const SizedBox(height: 6),
                Text('Thrown in: ${details.library}', style: textStyle),
              ],
              if (details.context != null) ...[
                const SizedBox(height: 6),
                Text('Context: ${details.context}', style: textStyle),
              ],
              if (stack != null) ...[
                const SizedBox(height: 4),
                Theme(
                  data: Theme.of(
                    context,
                  ).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    iconColor: colorScheme.onErrorContainer,
                    collapsedIconColor: colorScheme.onErrorContainer,
                    splashColor: Colors.transparent,
                    title: Text(
                      'Stack trace',
                      style: textStyle.copyWith(fontStyle: FontStyle.italic),
                    ),
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(stack, style: textStyle),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
