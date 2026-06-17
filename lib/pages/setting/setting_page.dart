import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:setting_ui_builder/setting_ui_builder.dart' show SettingsList, SettingsTile, SettingsSection;

import '../../common/app_colors.dart';
import '../../generated/l10n.dart';
import 'setting_cubit.dart';
import 'setting_state.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  late final SettingCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = SettingCubit();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<SettingCubit, SettingState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.oldLace,
            body: SettingsList(
              sections: [
                SettingsSection(
                  title: 'General',
                  tiles: [
                    SettingsTile.value(title: 'Language', value: 'English', onTap: () {}),
                    SettingsTile.toggle(title: 'Dark Mode', value: true, onToggle: (v) {}),
                  ],
                ),
                SettingsSection(
                  title: 'About',
                  tiles: [
                    SettingsTile.navigation(
                      leading: const Icon(Icons.description_outlined),
                      title: S.current.lb_terms,
                      onTap: () => context.push('/terms'),
                    ),
                    SettingsTile.navigation(
                      leading: const Icon(Icons.privacy_tip_outlined),
                      title: S.current.lb_policy,
                      onTap: () => context.push('/privacy'),
                    ),
                    SettingsTile.value(
                      leading: const Icon(Icons.info_outline),
                      title: 'App version',
                      value: 'v1.0.0',
                      onTap: null,
                    ),
                  ]
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
