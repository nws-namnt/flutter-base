/// All screens, cubits, states, and shared widgets of the app.
///
/// **Shell**
/// - [ShellPage] — root scaffold with bottom navigation bar
///
/// **Tab screens**
/// - [HomePage] / [HomeCubit] / [HomeState]
/// - [ServicePage] / [ServiceCubit] / [ServiceState]
/// - [SettingPage] / [SettingCubit] / [SettingState]
///
/// **Standalone screens**
/// - [SplashPage] / [SplashCubit] / [SplashState]
/// - [PrivacyPage] — Privacy Policy rendered from Markdown asset
/// - [TermsPage] — Terms of Service rendered from Markdown asset
///
/// **Shared widgets**
/// - [AnimatedBranchContainer] — animated tab body for [StatefulShellRoute]
/// - [NotFoundPage] — 404 fallback
/// - [TransitionPage] — [CustomTransitionPage] with [PageTransitionType]
/// - [ShellTransitionType] — transition styles for shell tab switches
// ignore: unnecessary_library_name
library pages;

export 'home/home_cubit.dart';
export 'home/home_page.dart';
export 'home/home_state.dart';
export 'privacy/privacy_page.dart';
export 'service/service_cubit.dart';
export 'service/service_page.dart';
export 'service/service_state.dart';
export 'setting/setting_cubit.dart';
export 'setting/setting_page.dart';
export 'setting/setting_state.dart';
export 'shell/shell_page.dart';
export 'splash/splash_cubit.dart';
export 'splash/splash_page.dart';
export 'splash/splash_state.dart';
export 'terms/terms_page.dart';
export 'widgets/animated_bottom_navigation_widget.dart';
export 'widgets/not_found_page.dart';
export 'widgets/transition_shell_widget.dart';
export 'widgets/transition_widget.dart';
