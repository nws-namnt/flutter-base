import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../common/app_env.dart';
import '../common/app_themes.dart';
import '../generated/l10n.dart' show S;
import '../routing/app_router.dart';
import '../routing/router_notifier.dart';
import 'app_cubit.dart';
import 'app_state.dart';

/// Root widget of the application.
///
/// Owns the [AppCubit], [RouterNotifier], and [AppRouter] instances.
/// Builds a [MaterialApp.router] that reacts to theme / locale changes
/// emitted by [AppCubit].
class AppPage extends StatefulWidget {
  /// Creates the root [AppPage].
  const AppPage({super.key});

  @override
  State<AppPage> createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> {
  late final RouterNotifier _routerNotifier;
  late final AppRouter _appRouter;

  static final _m3 = const M3Theme();
  static final _lightTheme = _m3.light;
  static final _darkTheme = _m3.dark;
  static final _lightHighContrastTheme = _m3.lightHighContrast;
  static final _darkHighContrastTheme = _m3.darkHighContrast;

  @override
  void initState() {
    super.initState();
    _routerNotifier = RouterNotifier();
    _appRouter = AppRouter(_routerNotifier);
  }

  @override
  void dispose() {
    _routerNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AppCubit(),
      child: BlocBuilder<AppCubit, AppState>(
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
            supportedLocales: const [Locale('en'), Locale('vi')],
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            routerConfig: _appRouter.goRouter,
          );
        },
      ),
    );
  }
}
