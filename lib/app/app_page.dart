import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../common/app_env.dart';
import '../common/app_themes.dart';
import '../generated/l10n.dart' show S;
import '../routing/app_router.dart' show appRouter;
import 'app_cubit.dart';
import 'app_state.dart';

/// Root widget of the application.
///
/// Provides [AppCubit] to the widget tree and builds a [MaterialApp.router]
/// that reacts to theme and locale changes. Navigation and auth-redirect
/// state are managed by the [AppRouter] singleton — see [appRouter] and
/// [routerNotifier] for context-free navigation.
class AppPage extends StatelessWidget {
  /// Creates the root [AppPage] widget.
  const AppPage({super.key});

  static final _m3 = const M3Theme();
  static final _lightTheme = _m3.light;
  static final _darkTheme = _m3.dark;
  static final _lightHighContrastTheme = _m3.lightHighContrast;
  static final _darkHighContrastTheme = _m3.darkHighContrast;

  /// Builds the [MaterialApp.router], reacting to [AppCubit] theme/locale changes.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AppCubit(),
      child: BlocBuilder<AppCubit, AppState>(
        buildWhen: (pre, cur) => pre.locale != cur.locale || pre.themeMode != cur.themeMode,
        builder: (context, state) {
          return MaterialApp.router(
            title: 'Flutter Base',
            debugShowCheckedModeBanner: AppEnv.showDebugBanner,
            themeMode: state.themeMode,
            theme: _lightTheme,
            darkTheme: _darkTheme,
            highContrastTheme: _lightHighContrastTheme,
            highContrastDarkTheme: _darkHighContrastTheme,
            locale: state.locale,
            supportedLocales: const [Locale('en'), Locale('vi'), Locale('ja')],
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}
