import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../pages/home/home_page.dart';
import '../pages/service/service_page.dart';
import '../pages/setting/setting_page.dart';
import '../pages/shell/shell_page.dart';
import '../pages/splash/splash_page.dart';
import '../pages/widgets/animated_bottom_navigation_widget.dart';
import '../pages/widgets/not_found_page.dart';
import '../pages/widgets/transition_widget.dart';
import 'routers.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: '_kRoot');
final shellKey = GlobalKey<StatefulNavigationShellState>(debugLabel: '_kShell');
final _homeBranchKey = GlobalKey<NavigatorState>(debugLabel: '_kHome');
final _serviceBranchKey = GlobalKey<NavigatorState>(debugLabel: '_kService');
final _settingBranchKey = GlobalKey<NavigatorState>(debugLabel: '_kSetting');

List<RouteBase> routes = [_splashRoute, _shellRoute, _notFoundRoute];

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
  // Wraps branch navigators with a fade-in animation on tab switch.
  navigatorContainerBuilder: (context, navigationShell, children) =>
      AnimatedBranchContainer(currentIndex: navigationShell.currentIndex, children: children),
  builder: (context, state, navigationShell) => ShellPage(shell: navigationShell),
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

// 404 fallback
GoRoute get _notFoundRoute => GoRoute(
  name: Routers.pageNotFound.routerName,
  path: Routers.pageNotFound.routerPath,
  pageBuilder: (context, state) => TransitionPage(child: const NotFoundPage(), transitionType: PageTransitionType.fade),
);
