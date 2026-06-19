import 'package:flutter/material.dart';

/// A [ChangeNotifier] used as [GoRouter.refreshListenable].
///
/// Call [attachAuthStateChange] after a successful login (or any event that
/// should trigger a route re-evaluation), and [detachAuthStateChange] on
/// logout. [GoRouter] subscribes to this notifier and re-runs its `redirect`
/// callback whenever it fires.
class RouterNotifier extends ChangeNotifier {
  bool _authCompleted = false;

  /// Whether the user has completed authentication.
  bool get authCompleted => _authCompleted;

  /// Marks auth as completed and notifies [GoRouter] to re-evaluate redirects.
  void attachAuthStateChange() {
    _authCompleted = true;
    notifyListeners();
  }

  /// Clears auth state and notifies [GoRouter] to re-evaluate redirects.
  void detachAuthStateChange() {
    _authCompleted = false;
    notifyListeners();
  }
}