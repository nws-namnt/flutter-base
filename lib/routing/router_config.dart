import 'package:flutter/widgets.dart';
import 'package:flutter_base/pages/widgets/bottom_sheet_widget.dart';
import 'package:go_router/go_router.dart';

import '../common/app_colors.dart';
import '../pages/pages.dart';
import 'routers.dart';

/// Root [NavigatorState] key shared between [AppRouter] and route builders.
///
/// Required by [StatefulShellRoute.parentNavigatorKey] so routes that need
/// to push above the shell (e.g. full-screen dialogs) can use the root navigator.
final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: '_kRoot');

/// Key for the [StatefulNavigationShell] that hosts the bottom-nav branches.
final shellKey = GlobalKey<StatefulNavigationShellState>(debugLabel: '_kShell');

// Branch navigator keys — one per tab in [ShellPage].
final _homeBranchKey = GlobalKey<NavigatorState>(debugLabel: '_kHome');
final _serviceBranchKey = GlobalKey<NavigatorState>(debugLabel: '_kService');
final _exploreBranchKey = GlobalKey<NavigatorState>(debugLabel: '_kExplore');
final _settingBranchKey = GlobalKey<NavigatorState>(debugLabel: '_kSetting');

/// Top-level route list consumed by [GoRouter].
///
/// Order matters: GoRouter matches routes top-to-bottom.
List<RouteBase> routes = [
  _splashRoute,
  _introRoute,
  _shellRoute,
  _termRoute,
  _privacyRoute,
  _imagePreviewRoute,
  _aiSupportRoute,
  _languageSheetRoute,
  _notFoundRoute,
];

// Splash — entry point
GoRoute get _splashRoute => GoRoute(
  name: Routers.root.routerName,
  path: Routers.root.routerPath,
  pageBuilder: (context, state) => TransitionPage(
    child: const SplashPage(),
    transitionType: PageTransitionType.fade,
  ),
);

// Onboarding
GoRoute get _introRoute => GoRoute(
  name: Routers.intro.routerName,
  path: Routers.intro.routerPath,
  pageBuilder: (context, state) => TransitionPage(
    child: const IntroPage(),
    transitionType: PageTransitionType.fade,
  ),
);

// Shell — home with bottom navigation bar
StatefulShellRoute get _shellRoute => StatefulShellRoute(
  parentNavigatorKey: rootNavigatorKey,
  key: shellKey,
  builder: (context, state, navigationShell) => navigationShell,
  navigatorContainerBuilder: (context, navigationShell, children) =>
      ShellPage(shell: navigationShell, children: children),
  branches: [
    // Branch 0 — Home
    StatefulShellBranch(
      navigatorKey: _homeBranchKey,
      routes: [
        GoRoute(
          name: Routers.home.routerName,
          path: Routers.home.routerPath,
          pageBuilder: (context, state) => TransitionPage(
            child: const HomePage(),
            transitionType: PageTransitionType.fade,
          ),
        ),
      ],
    ),

    // Branch 1 — Service
    StatefulShellBranch(
      navigatorKey: _serviceBranchKey,
      routes: [
        GoRoute(
          name: Routers.service.routerName,
          path: Routers.service.routerPath,
          pageBuilder: (context, state) => TransitionPage(
            child: const ServicePage(),
            transitionType: PageTransitionType.fade,
          ),
        ),
      ],
    ),

    // Branch 2 — Explore
    StatefulShellBranch(
      navigatorKey: _exploreBranchKey,
      routes: [
        GoRoute(
          name: Routers.explore.routerName,
          path: Routers.explore.routerPath,
          pageBuilder: (context, state) => TransitionPage(
            child: const ExplorePage(),
            transitionType: PageTransitionType.fade,
          ),
        ),
      ],
    ),

    // Branch 3 — Settings
    StatefulShellBranch(
      navigatorKey: _settingBranchKey,
      routes: [
        GoRoute(
          name: Routers.setting.routerName,
          path: Routers.setting.routerPath,
          pageBuilder: (context, state) => TransitionPage(
            child: const SettingPage(),
            transitionType: PageTransitionType.fade,
          ),
        ),
      ],
    ),
  ],
);

// Pages
GoRoute get _termRoute => GoRoute(
  name: Routers.terms.routerName,
  path: Routers.terms.routerPath,
  pageBuilder: (context, state) => TransitionPage(
    child: const TermsPage(),
    transitionType: PageTransitionType.sharedAxisHorizontal,
  ),
);

GoRoute get _privacyRoute => GoRoute(
  name: Routers.privacy.routerName,
  path: Routers.privacy.routerPath,
  pageBuilder: (context, state) => TransitionPage(
    child: const PrivacyPage(),
    transitionType: PageTransitionType.sharedAxisHorizontal,
  ),
);

GoRoute get _imagePreviewRoute => GoRoute(
  name: Routers.imagePreview.routerName,
  path: Routers.imagePreview.routerPath,
  pageBuilder: (context, state) {
    // Pushed via HeroImageWidget with extra: {'heroTag': String, 'child': Widget}
    // — Widget can't be encoded in a URL, so it must travel through `extra`.
    final extra = state.extra as Map<String, dynamic>?;
    assert(
      extra != null && extra['heroTag'] is String && extra['child'] is Widget,
      'imagePreview route requires extra: {heroTag: String, child: Widget} — '
      'push it via HeroImageWidget, not directly.',
    );
    return TransitionPage(
      opaque: false,
      barrierColor: AppColors.inkBlack,
      child: ImagePreviewPage(
        heroTag: extra!['heroTag'] as String,
        child: extra['child'] as Widget,
      ),
      transitionType: PageTransitionType.fade,
    );
  },
);

// Bottom sheet
GoRoute get _languageSheetRoute => GoRoute(
  name: Routers.languageSheet.routerName,
  path: Routers.languageSheet.routerPath,
  pageBuilder: (context, state) => BottomSheetWidget.unScroll(
    builder: (context) => const LanguageBottomSheet(),
    barrierLabel: Routers.languageSheet.routerName,
    isDismissible: false,
  ),
);

// AI Support chat
GoRoute get _aiSupportRoute => GoRoute(
  name: Routers.aiSupport.routerName,
  path: Routers.aiSupport.routerPath,
  pageBuilder: (context, state) {
    final extra = state.extra as Map<String, dynamic>?;
    final screenName = extra?['screenName'] as String? ?? 'App';
    return TransitionPage(
      child: AiSupportPage(screenName: screenName),
      transitionType: PageTransitionType.slideFromRight,
    );
  },
);

// 404 fallback
GoRoute get _notFoundRoute => GoRoute(
  name: Routers.pageNotFound.routerName,
  path: Routers.pageNotFound.routerPath,
  pageBuilder: (context, state) => TransitionPage(
    child: const NotFoundPage(),
    transitionType: PageTransitionType.slideFromRight,
  ),
);
