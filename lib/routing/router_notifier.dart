import 'package:flutter/material.dart';

class RouterNotifier extends ChangeNotifier {
  bool _authCompleted = false;

  bool get authCompleted => _authCompleted;

  void attachAuthStateChange() {
    _authCompleted = true;
    notifyListeners();
  }

  void detachAuthStateChange() {
    _authCompleted = false;
    notifyListeners();
  }
}