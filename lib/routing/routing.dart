/// Navigation layer — GoRouter configuration, route registry, and helpers.
///
/// - [Routers] — enum of all named routes with path + name pairs
/// - [AppRouter] — [GoRouter] instance wired to [RouterNotifier]
/// - [RouterNotifier] — [ChangeNotifier] that triggers redirect re-evaluation
/// - [RouterObserver] — [NavigatorObserver] that logs route lifecycle events
/// - [RouterExtension] — convenience helpers on [BuildContext] (back, goHome…)
/// - [GoRouterExtension] — context-free [GoRouter.location] getter
// ignore: unnecessary_library_name
library routing;

export 'app_router.dart';
export 'router_config.dart';
export 'router_extension.dart';
export 'router_notifier.dart';
export 'router_observer.dart';
export 'routers.dart';
