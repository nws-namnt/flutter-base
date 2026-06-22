import 'package:flutter/widgets.dart';
import 'package:flutter_base/pages/widgets/bottom_sheet_widget.dart';
import 'package:go_router/go_router.dart';

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
final _settingBranchKey = GlobalKey<NavigatorState>(debugLabel: '_kSetting');

/// Top-level route list consumed by [GoRouter].
///
/// Order matters: GoRouter matches routes top-to-bottom.
List<RouteBase> routes = [
  _splashRoute,
  _shellRoute,
  _termRoute,
  _privacyRoute,
  _languageSheetRoute,
  _notFoundRoute,
];

// Splash — entry point
GoRoute get _splashRoute => GoRoute(
  name: Routers.root.routerName,
  path: Routers.root.routerPath,
  pageBuilder: (context, state) => TransitionPage(child: const SplashPage(), transitionType: PageTransitionType.fade),
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
          pageBuilder: (context, state) =>
              TransitionPage(child: const HomePage(), transitionType: PageTransitionType.fade),
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
          pageBuilder: (context, state) =>
              TransitionPage(child: const ServicePage(), transitionType: PageTransitionType.fade),
        ),
      ],
    ),

    // Branch 2 — Settings
    StatefulShellBranch(
      navigatorKey: _settingBranchKey,
      routes: [
        GoRoute(
          name: Routers.setting.routerName,
          path: Routers.setting.routerPath,
          pageBuilder: (context, state) =>
              TransitionPage(child: const SettingPage(), transitionType: PageTransitionType.fade),
        ),
      ],
    ),
  ],
);

// Pages
GoRoute get _termRoute => GoRoute(
  name: Routers.terms.routerName,
  path: Routers.terms.routerPath,
  pageBuilder: (context, state) => TransitionPage(child: const TermsPage(), transitionType: PageTransitionType.slideFromRight),
);

GoRoute get _privacyRoute => GoRoute(
  name: Routers.privacy.routerName,
  path: Routers.privacy.routerPath,
  pageBuilder: (context, state) => TransitionPage(child: const PrivacyPage(), transitionType: PageTransitionType.slideFromRight),
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

// 404 fallback
GoRoute get _notFoundRoute => GoRoute(
  name: Routers.pageNotFound.routerName,
  path: Routers.pageNotFound.routerPath,
  pageBuilder: (context, state) => TransitionPage(child: const NotFoundPage(), transitionType: PageTransitionType.slideFromRight),
);
