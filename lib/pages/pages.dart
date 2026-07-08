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
/// - [HomeDetailPage] / [HomeDetailCubit] / [HomeDetailState] — opened from
///   [HomePage] via [OpenContainerWrapper]
/// - [PrivacyPage] — Privacy Policy rendered from Markdown asset
/// - [TermsPage] — Terms of Service rendered from Markdown asset
///
/// **Shared widgets**
/// - [AnimatedBranchContainer] — animated tab body for [StatefulShellRoute]
/// - [CachedImageWidget] — themed wrapper over `cached_network_image`
/// - [NotFoundPage] — 404 fallback
/// - [TransitionPage] — [CustomTransitionPage] with [PageTransitionType]
/// - [ShellTransitionType] — transition styles for shell tab switches
/// - [FadeWrapper] / [FadeThroughWrapper] / [SharedAxisTransitionWrapper] /
///   [OpenContainerWrapper] — documented wrappers over the `animations`
///   package's Material motion patterns
// ignore: unnecessary_library_name
library pages;

export 'ai_support/ai_support_page.dart';
export 'home/home_page.dart';
export 'home_detail/home_detail_page.dart';
export 'privacy/privacy_page.dart';
export 'service/service_page.dart';
export 'setting/setting_page.dart';
export 'shell/shell_page.dart';
export 'splash/splash_page.dart';
export 'terms/terms_page.dart';
export 'widgets/animated_bottom_navigation_widget.dart';
export 'widgets/animations_wrapper/fade_through_wrapper.dart';
export 'widgets/animations_wrapper/fade_wrapper.dart';
export 'widgets/animations_wrapper/open_container_wrapper.dart';
export 'widgets/animations_wrapper/shared_axis_transition_wrapper.dart';
export 'widgets/cached_image_widget.dart';
export 'widgets/language_sheet_widget.dart';
export 'widgets/not_found_page.dart';
export 'widgets/transition_shell_widget.dart';
export 'widgets/transition_widget.dart';
