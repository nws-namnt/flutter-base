import 'package:flutter/material.dart';
import 'package:flutter_base/common/app_enums.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:setting_ui_builder/setting_ui_builder.dart' show SettingsList, SettingsTile, SettingsSection;

import '../../app/app_cubit.dart';
import '../../app/app_state.dart';
import '../../common/app_colors.dart';
import '../../generated/l10n.dart';
import '../../routing/routers.dart';
import 'setting_cubit.dart';
import 'setting_state.dart';

/// The Settings tab screen, hosted inside the navigation shell at [Routers.setting].
///
/// Displays language, theme, and app-info tiles using the `setting_ui_builder` package.
/// Instantiates and owns its [SettingCubit]; the cubit is closed in [dispose].
class SettingPage extends StatefulWidget {
  /// Creates a [SettingPage].
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
        builder: (context, _) {
          // React to locale changes from AppCubit.
          return BlocBuilder<AppCubit, AppState>(
            buildWhen: (pre, cur) => pre.locale != cur.locale || pre.themeMode != cur.themeMode,
            builder: (context, appState) {
              final currentLanguage = AppLanguage.values.firstWhere(
                (e) => e.locale.languageCode == appState.locale.languageCode,
                orElse: () => AppLanguage.values.first,
              ).label;

              return Scaffold(
                backgroundColor: AppColors.oldLace,
                body: SettingsList(
                  sections: [
                    SettingsSection(
                      title: S.current.lb_general,
                      tiles: [
                        SettingsTile.value(
                          leading: const Icon(Icons.language_outlined),
                          title: S.current.lb_language,
                          value: currentLanguage,
                          onTap: () => context.push(Routers.languageSheet.routerPath),
                        ),
                        SettingsTile.toggle(
                          leading: const Icon(Icons.dark_mode_outlined),
                          title: S.current.lb_dark_mode,
                          value: appState.themeMode == ThemeMode.dark,
                          onToggle: (v) => context.read<AppCubit>().setThemeMode(
                            v ? ThemeMode.dark : ThemeMode.light,
                          ),
                        ),
                      ],
                    ),
                    SettingsSection(
                      title: S.current.lb_about,
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
                          title: S.current.lb_version,
                          value: 'v1.0.0',
                          onTap: null,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
