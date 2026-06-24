import 'package:go_router/go_router.dart';

import '../common/app_env.dart';
import '../pages/widgets/not_found_page.dart';
import 'router_config.dart' show rootNavigatorKey, routes;
import 'router_notifier.dart';
import 'router_observer.dart';
import 'routers.dart';

/// Global read-only accessor for the [GoRouter] singleton.
///
/// Use this to navigate from anywhere — Cubits, Services, FCM handlers —
/// without needing a [BuildContext].
///
/// ```dart
/// import 'package:flutter_base/routing/app_router.dart';
///
/// // Navigate from a Cubit or Service
/// appRouter.go(Routers.home.routerPath);
/// appRouter.push(Routers.setting.routerPath);
/// appRouter.pop();
/// ```
GoRouter get appRouter => AppRouter.instance.goRouter;

/// Global read-only accessor for the [RouterNotifier] singleton.
///
/// Call [RouterNotifier.attachAuthStateChange] after a successful login and
/// [RouterNotifier.detachAuthStateChange] after logout to force [GoRouter]
/// to re-evaluate its `redirect` callback.
///
/// ```dart
/// import 'package:flutter_base/routing/app_router.dart';
///
/// // After login succeeds
/// routerNotifier.attachAuthStateChange();
///
/// // After logout
/// routerNotifier.detachAuthStateChange();
/// ```
RouterNotifier get routerNotifier => AppRouter.instance.notifier;

/// Singleton that owns the app's [GoRouter] and [RouterNotifier].
///
/// Both are created once on first access via [AppRouter.instance] and reused
/// for the entire app lifetime. Prefer the top-level convenience getters
/// [appRouter] and [routerNotifier] over accessing [AppRouter.instance] directly.
///
/// ## Why singleton?
///
/// [GoRouter] must not be re-created — doing so resets navigation state and
/// spawns duplicate route listeners. A singleton guarantees exactly one
/// instance regardless of how many times [AppRouter.instance] is called.
///
/// ## Navigating without a BuildContext
///
/// ```dart
/// // From a Cubit after an API call
/// appRouter.go(Routers.home.routerPath);
///
/// // Trigger a redirect after login / logout
/// routerNotifier.attachAuthStateChange();
/// ```
class AppRouter {
  AppRouter._();

  static final AppRouter _instance = AppRouter._();

  /// The single [AppRouter] instance for this process.
  ///
  /// Prefer [appRouter] / [routerNotifier] top-level getters for day-to-day use.
  static AppRouter get instance => _instance;

  /// The [RouterNotifier] that drives auth-based route redirects.
  ///
  /// Registered as [GoRouter.refreshListenable] so any call to
  /// [RouterNotifier.attachAuthStateChange] or [RouterNotifier.detachAuthStateChange]
  /// immediately re-runs the router's `redirect` callback.
  ///
  /// Prefer the top-level [routerNotifier] getter over [AppRouter.instance.notifier].
  final RouterNotifier notifier = RouterNotifier();

  /// The configured [GoRouter] instance passed to [MaterialApp.router].
  ///
  /// Created lazily on first access via `late final` — subsequent accesses
  /// return the same instance. Prefer the top-level [appRouter] getter.
  late final GoRouter goRouter = GoRouter(
    initialLocation: Routers.root.routerPath,
    navigatorKey: rootNavigatorKey,
    debugLogDiagnostics: AppEnv.enableLogging,
    refreshListenable: notifier,
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
