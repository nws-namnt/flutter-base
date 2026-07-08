import 'package:flutter/widgets.dart';

// ─── Enum ────────────────────────────────────────────────────────────────────

/// Visual and interactive behaviour of a [SettingsTile].
enum SettingsTileType {
  /// Chevron arrow + optional trailing text. Tap to navigate.
  navigation,

  /// [Switch] widget. Tap anywhere on the row to flip.
  toggle,

  /// Read-only trailing text. Tap to pick/change via dialog or bottom sheet.
  value,

  /// Free-form trailing widget slot.
  custom,
}

// ─── SettingsTile ─────────────────────────────────────────────────────────────

/// Immutable configuration for a single settings row.
///
/// Use the named factory constructors:
/// ```dart
/// SettingsTile.toggle(title: 'Dark mode', value: isDark, onToggle: ...)
/// SettingsTile.navigation(title: 'Language', value: 'English', onTap: ...)
/// SettingsTile.value(title: 'Font size', value: 'Medium', onTap: ...)
/// SettingsTile.custom(title: 'Accent colour', trailing: ColourChip())
/// ```
class SettingsTile {
  const SettingsTile._({
    required this.type,
    required this.title,
    this.leading,
    this.subtitle,
    this.displayValue,
    this.toggled,
    this.onToggle,
    this.onTap,
    this.trailing,
    this.enabled = true,
  });

  final SettingsTileType type;
  final Widget? leading;
  final String title;
  final String? subtitle;

  /// Trailing text for [SettingsTileType.navigation] / [SettingsTileType.value].
  final String? displayValue;

  /// Current state for [SettingsTileType.toggle].
  final bool? toggled;

  /// Called with the new value when [SettingsTileType.toggle] is flipped.
  final ValueChanged<bool>? onToggle;

  /// Called when the tile is tapped, for [SettingsTileType.navigation],
  /// [SettingsTileType.value], and [SettingsTileType.custom].
  final VoidCallback? onTap;

  /// Free-form trailing for [SettingsTileType.custom].
  final Widget? trailing;

  /// Renders at 38 % opacity and ignores all interactions when false.
  final bool enabled;

  /// Creates a tile that shows a chevron arrow (and optional trailing
  /// [value] text) and calls [onTap] to navigate elsewhere.
  factory SettingsTile.navigation({
    Widget? leading,
    required String title,
    String? subtitle,
    String? value,
    VoidCallback? onTap,
    bool enabled = true,
  }) =>
      SettingsTile._(
        type: SettingsTileType.navigation,
        leading: leading,
        title: title,
        subtitle: subtitle,
        displayValue: value,
        onTap: onTap,
        enabled: enabled,
      );

  /// Creates a tile with a [Switch] reflecting [value], calling [onToggle]
  /// when its state changes (including a tap anywhere on the row).
  factory SettingsTile.toggle({
    Widget? leading,
    required String title,
    String? subtitle,
    required bool value,
    ValueChanged<bool>? onToggle,
    bool enabled = true,
  }) =>
      SettingsTile._(
        type: SettingsTileType.toggle,
        leading: leading,
        title: title,
        subtitle: subtitle,
        toggled: value,
        onToggle: onToggle,
        enabled: enabled,
      );

  /// Creates a tile showing read-only trailing [value] text, calling
  /// [onTap] to let the user pick or change it via a dialog or sheet.
  factory SettingsTile.value({
    Widget? leading,
    required String title,
    String? subtitle,
    String? value,
    VoidCallback? onTap,
    bool enabled = true,
  }) =>
      SettingsTile._(
        type: SettingsTileType.value,
        leading: leading,
        title: title,
        subtitle: subtitle,
        displayValue: value,
        onTap: onTap,
        enabled: enabled,
      );

  /// Creates a tile with a free-form [trailing] widget slot.
  factory SettingsTile.custom({
    Widget? leading,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    bool enabled = true,
  }) =>
      SettingsTile._(
        type: SettingsTileType.custom,
        leading: leading,
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        onTap: onTap,
        enabled: enabled,
      );
}

// ─── SettingsSection ─────────────────────────────────────────────────────────

/// Groups [tiles] under an optional [title] label.
class SettingsSection {
  /// Creates a section with an optional [title] and its [tiles].
  const SettingsSection({
    this.title,
    required this.tiles,
  });

  /// Optional label rendered above the section's card.
  final String? title;

  /// The tiles rendered inside the section's card, in order.
  final List<SettingsTile> tiles;
}
