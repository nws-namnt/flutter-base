import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../common/app_enums.dart' show LoadStatus;
import '../../routing/routers.dart';
import 'splash_cubit.dart';
import 'splash_state.dart';

/// Animated splash screen shown at app startup (`/`).
///
/// Creates a [SplashCubit] and immediately calls [SplashCubit.onInitialize].
/// When the cubit emits [LoadStatus.success], the listener navigates to
/// [Routers.intro] on first launch, or straight to [Routers.home] once
/// onboarding has already been seen — see [SplashState.hasSeenIntro].
///
/// Status-bar style is synced to the active [Brightness] via
/// [AnnotatedRegion] so the system icons remain legible.
class SplashPage extends StatefulWidget {
  /// Creates a [SplashPage].
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late final SplashCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = SplashCubit();
    _cubit.onInitialize();
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
      child: BlocConsumer<SplashCubit, SplashState>(
        listenWhen: (_, curr) => curr.status == LoadStatus.success,
        listener: (context, state) => context.go(
          state.isCompletedIntro ? Routers.home.routerPath : Routers.intro.routerPath,
        ),
        builder: (context, state) {
          final bgColor = Theme.of(context).colorScheme.surface;
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final style = state.status == LoadStatus.loading
              ? FlutterLogoStyle.horizontal
              : FlutterLogoStyle.markOnly;

          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              statusBarColor: bgColor,
              statusBarIconBrightness:
                  isDark ? Brightness.light : Brightness.dark,
              statusBarBrightness:
                  isDark ? Brightness.dark : Brightness.light,
            ),
            child: Scaffold(
              backgroundColor: bgColor,
              extendBodyBehindAppBar: true,
              body: SizedBox.expand(
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                    child: FlutterLogo(
                      key: ValueKey(style),
                      size: 120,
                      style: style,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
