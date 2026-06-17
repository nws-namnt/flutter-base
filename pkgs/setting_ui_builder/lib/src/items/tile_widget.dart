import 'package:flutter/material.dart';

import '../models.dart';

/// Renders a single [SettingsTile] based on its [SettingsTileType].
///
/// Uses a Dart-3 switch expression to resolve [trailing] and [onTap]
/// for each type, keeping [build] lean.
class SettingsTileWidget extends StatelessWidget {
  const SettingsTileWidget({super.key, required this.tile});

  final SettingsTile tile;

  // ── Resolve trailing widget + effective tap per type ────────────────────────

  ({Widget? trailing, VoidCallback? onTap}) _resolve(
    ColorScheme scheme,
    TextTheme textTheme,
  ) {
    final valueStyle =
        textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant);

    return switch (tile.type) {
      SettingsTileType.navigation => (
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (tile.displayValue != null)
                Text(tile.displayValue!, style: valueStyle),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                color: scheme.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
          onTap: tile.enabled ? tile.onTap : null,
        ),

      SettingsTileType.toggle => (
          trailing: Switch(
            value: tile.toggled ?? false,
            onChanged: tile.enabled ? tile.onToggle : null,
          ),
          // Tap the whole row to flip the switch
          onTap: tile.enabled
              ? () => tile.onToggle?.call(!(tile.toggled ?? false))
              : null,
        ),

      SettingsTileType.value => (
          trailing: tile.displayValue != null
              ? Text(tile.displayValue!, style: valueStyle)
              : null,
          onTap: tile.enabled ? tile.onTap : null,
        ),

      SettingsTileType.custom => (
          trailing: tile.trailing,
          onTap: tile.enabled ? tile.onTap : null,
        ),
    };
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final (:trailing, :onTap) = _resolve(scheme, textTheme);

    final tile = ListTile(
      enabled: this.tile.enabled,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: this.tile.leading != null
          ? IconTheme(
              data: IconThemeData(color: scheme.onSurface, size: 22),
              child: this.tile.leading!,
            )
          : null,
      title: Text(this.tile.title),
      subtitle: this.tile.subtitle != null
          ? Text(
              this.tile.subtitle!,
              style:
                  textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            )
          : null,
      trailing: trailing,
      onTap: onTap,
    );

    return this.tile.enabled
        ? tile
        : Opacity(opacity: 0.38, child: tile);
  }
}
