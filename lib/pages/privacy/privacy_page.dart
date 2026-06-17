import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import '../../utils/extensions/context_extension.dart' show ContextExtension;

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  static final _content = rootBundle.loadString('assets/docs/privacy.md');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
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
