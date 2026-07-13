import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// A [ChangeNotifier] used as [GoRouter.refreshListenable].
///
/// Subscribes to [FirebaseAuth.authStateChanges] and calls [notifyListeners]
/// on every auth event so [GoRouter] re-evaluates its redirect and any
/// [ListenableBuilder] watching this notifier (e.g. the drawer header) rebuilds
/// immediately without needing a [StreamBuilder] or [setState] in the page.
class RouterNotifier extends ChangeNotifier {
  RouterNotifier() {
    _currentUser = FirebaseAuth.instance.currentUser;
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  User? _currentUser;

  /// The currently signed-in user, or `null` if not authenticated.
  /// Always in sync with [FirebaseAuth.instance.currentUser].
  User? get currentUser => _currentUser;

  late final StreamSubscription<User?> _authSub;

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }
}
