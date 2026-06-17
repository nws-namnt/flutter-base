import 'package:flutter/cupertino.dart';
import 'package:flutter_base/routing/routers.dart';
import 'package:go_router/go_router.dart';

extension RouterExtension on BuildContext {
  void get reset => GoRouter.of(this).refresh();

  bool get canBack => GoRouter.of(this).canPop();

  void get back => GoRouter.of(this).pop();

  void backWithResult<T extends Object?>([T? result]) => GoRouter.of(this).pop(result);

  void get goHome => GoRouter.of(this).go(Routers.home.routerPath);
}

extension GoRouterExtension on GoRouter {
  // Provide method to get current router location without context
  String get location {
    final RouteMatch lastMatch = routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }
}