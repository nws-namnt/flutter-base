import 'package:flutter/material.dart';

import 'items/section_widget.dart';
import 'models.dart';

/// Root widget — renders a scrollable list of [SettingsSection]s.
///
/// ```dart
/// SettingsList(
///   sections: [
///     SettingsSection(
///       title: 'Appearance',
///       tiles: [
///         SettingsTile.toggle(
///           leading: const Icon(Icons.dark_mode_outlined),
///           title: 'Dark mode',
///           value: state.isDark,
///           onToggle: (v) => context.read<AppCubit>().toggleTheme(v),
///         ),
///         SettingsTile.navigation(
///           leading: const Icon(Icons.language_outlined),
///           title: 'Language',
///           value: 'English',
///           onTap: () => context.push('/language'),
///         ),
///       ],
///     ),
///   ],
/// )
/// ```
class SettingsList extends StatelessWidget {
  const SettingsList({
    super.key,
    required this.sections,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  });

  final List<SettingsSection> sections;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding,
      itemCount: sections.length,
      separatorBuilder: (mContext, i) => const SizedBox(height: 20),
      itemBuilder: (mContext, i) => SettingsSectionWidget(section: sections[i]),
    );
  }
}
