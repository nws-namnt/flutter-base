import 'package:flutter/material.dart';

import '../utils/app_logger.dart';

/// [NavigatorObserver] that logs every route lifecycle event via [info].
///
/// Registered in [AppRouter.goRouter] via the `observers` parameter.
/// Useful for debugging navigation flows during development.
class RouterObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    info('PUSH TO $route FROM $previousRoute');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    info('POP TO $route FROM $previousRoute');
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    info('REMOVE $route FROM $previousRoute');
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    info('REPLACE ROUTER $newRoute BY $oldRoute');
  }

  @override
  void didStartUserGesture(Route<dynamic> route, Route<dynamic>? previousRoute) => info('didStartUserGesture: $route, previousRoute= $previousRoute');

  @override
  void didStopUserGesture() => info('didStopUserGesture');
}