import 'package:flutter/material.dart';

import '../models.dart';
import 'tile_widget.dart';

/// Renders a [SettingsSection]: an optional title label above a rounded card
/// containing the tiles separated by hairline dividers.
class SettingsSectionWidget extends StatelessWidget {
  /// Creates a widget that renders [section].
  const SettingsSectionWidget({super.key, required this.section});

  /// The section data (title and tiles) to render.
  final SettingsSection section;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (section.title != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              section.title!.toUpperCase(),
              style: textTheme.labelSmall?.copyWith(
                color: scheme.primary,
                letterSpacing: 0.8,
              ),
            ),
          ),
        Material(
          color: scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: _buildTiles(scheme),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildTiles(ColorScheme scheme) {
    final List<Widget> items = [];
    for (int i = 0; i < section.tiles.length; i++) {
      items.add(SettingsTileWidget(tile: section.tiles[i]));
      if (i < section.tiles.length - 1) {
        items.add(Divider(
          height: 1,
          indent: section.tiles[i].leading != null ? 56 : 16,
          color: scheme.outlineVariant.withValues(alpha: 0.5),
        ));
      }
    }
    return items;
  }
}
