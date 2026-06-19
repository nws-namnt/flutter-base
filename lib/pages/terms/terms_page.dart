import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import '../../utils/extensions/context_extension.dart' show ContextExtension;

/// Displays the Terms of Service loaded from `assets/docs/terms.md`.
///
/// The Markdown content is rendered with [ContextExtension.m3MarkdownStyle]
/// so it adapts automatically to light/dark theme changes.
class TermsPage extends StatelessWidget {
  /// Creates a [TermsPage].
  const TermsPage({super.key});

  // Loaded once at class-init time; the Future is cached so rebuilds don't re-read the asset.
  static final _content = rootBundle.loadString('assets/docs/terms.md');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terms of Service')),
      body: FutureBuilder<String>(
        future: _content,
        builder: (context, snapshot) => switch (snapshot.connectionState) {
          ConnectionState.done when snapshot.hasData => Markdown(
              data: snapshot.data!,
              styleSheet: context.m3MarkdownStyle,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ConnectionState.done => Center(child: Text('${snapshot.error}')),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}
