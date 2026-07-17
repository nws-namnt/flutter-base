import 'package:flutter/cupertino.dart';
import 'package:flutter_base/routing/routers.dart';
import 'package:go_router/go_router.dart';

/// Convenience navigation helpers on [BuildContext].
///
/// Use these instead of calling [GoRouter.of(context)] directly so that
/// navigation intent is expressed as readable, one-word getters.
extension RouterExtension on BuildContext {
  /// Forces [GoRouter] to re-evaluate its `redirect` callback.
  void get reset => GoRouter.of(this).refresh();

  /// Pops the top-most route (e.g. a dialog) via the nearest [Navigator].
  void get backDialog => Navigator.pop(this);

  /// Whether the current route can be popped.
  bool get canBack => GoRouter.of(this).canPop();

  /// Pops the current route.
  void get back => GoRouter.of(this).pop();

  /// Pops the current route, optionally returning [result] to the caller.
  void backWithResult<T extends Object?>([T? result]) => GoRouter.of(this).pop(result);

  /// Navigates to [Routers.home], clearing the back stack.
  void get goHome => GoRouter.of(this).go(Routers.home.routerPath);
}

/// Helpers on [GoRouter] that do not require a [BuildContext].
extension GoRouterExtension on GoRouter {
  /// Returns the current URI string of the active route without needing a context.
  ///
  /// Walks the [routerDelegate]'s configuration to find the effective URI,
  /// correctly handling [ImperativeRouteMatch] (imperative push) entries.
  String get location {
    final RouteMatch lastMatch = routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }
}