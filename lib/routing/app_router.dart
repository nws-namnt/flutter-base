import 'package:go_router/go_router.dart';

import '../pages/widgets/not_found_page.dart';
import 'router_config.dart' show rootNavigatorKey, routes;
import 'router_notifier.dart';
import 'router_observer.dart';
import 'routers.dart';

class AppRouter {
  final RouterNotifier routerNotifier;

  AppRouter(this.routerNotifier);

  GoRouter get goRouter => GoRouter(
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
