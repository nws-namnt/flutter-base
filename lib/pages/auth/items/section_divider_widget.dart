import 'package:flutter/material.dart';
import 'package:flutter_base/utils/extensions/extensions.dart';

/// "──── or ────" row divider used between the email form and OAuth buttons.
class SectionDividerWidget extends StatelessWidget {
  const SectionDividerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Divider().expanded,
        Text(
          'or',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ).symPad(horizontal: 16),
        const Divider().expanded,
      ],
    );
  }
}