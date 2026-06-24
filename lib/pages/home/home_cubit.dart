import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'home_state.dart';

/// Cubit for the [HomePage].
///
/// Owns and emits [HomeState]. Extend with business logic as the
/// Home feature grows (e.g. fetching data, handling user actions).
class HomeCubit extends Cubit<HomeState> {
  /// Creates [HomeCubit] with the default [HomeState].
  HomeCubit() : super(const HomeState()) {
    _logFirebaseFlavor();
  }

  // TODO: remove after verifying flavor config
  void _logFirebaseFlavor() {
    final app = Firebase.app();
    debugPrint('🔥 Firebase loaded: project=${app.options.projectId}, appId=${app.options.appId}');
  }
}
