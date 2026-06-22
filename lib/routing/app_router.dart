import 'package:go_router/go_router.dart';

import '../pages/widgets/not_found_page.dart';
import 'router_config.dart' show rootNavigatorKey, routes;
import 'router_notifier.dart';
import 'router_observer.dart';
import 'routers.dart';

/// Configures and exposes the app's [GoRouter] instance.
///
/// Wires together [RouterNotifier], [RouterObserver], and the route tree
/// defined in [router_config.dart]. Instantiated once in [AppPage.initState].
class AppRouter {
  /// The [RouterNotifier] used as [GoRouter.refreshListenable].
  ///
  /// Trigger [RouterNotifier.attachAuthStateChange] / [RouterNotifier.detachAuthStateChange]
  /// to force a redirect evaluation (e.g. after login / logout).
  final RouterNotifier routerNotifier;

  /// Creates an [AppRouter] wired to the given [routerNotifier].
  AppRouter(this.routerNotifier);

  GoRouter get goRouter => _goRouter;

  /// The configured [GoRouter] instance to pass to [MaterialApp.router].
  GoRouter get _goRouter => GoRouter(
    initialLocation: Routers.root.routerPath,
    navigatorKey: rootNavigatorKey,
    debugLogDiagnostics: true,
    refreshListenable: routerNotifier,
    errorBuilder: (context, state) => const NotFoundPage(),
    redirect: (context, state) {
      // Always use routerPath (not routerName) for redirect return values.
      if (state.matchedLocation == Routers.pageNotFound.routerPath) {
        return Routers.home.routerPath;
      }
      return null;
    },
    redirectLimit: 10,
    observers: [RouterObserver()],
    routes: routes,
  );
}
