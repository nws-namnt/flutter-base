import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show FloatingActionButtonLocation;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'home_state.dart';

/// Cubit for the [HomePage].
///
/// Owns and emits [HomeState]. Extend with business logic as the
/// Home feature grows (e.g. fetching data, handling user actions).
class HomeCubit extends Cubit<HomeState> {
  /// Creates [HomeCubit] with the default [HomeState].
  HomeCubit() : super(const HomeInitial()) {
    _logFirebaseFlavor();
  }

  /// Loads the initial list of items.
  ///
  /// Emits [HomeLoading] then, after a simulated delay, [HomeSuccess] with
  /// 20 generated placeholder items.
  Future<void> initialize() async {
    emit(const HomeLoading());
    final data = List.generate(20, (i) {
      return 'Item ${i + 1}';
    }).toList();
    await Future.delayed(const Duration(seconds: 2));
    emit(HomeSuccess(data: data));
  }

  /// Appends a new placeholder item to the current [HomeSuccess.data].
  ///
  /// No-op if the current state is not [HomeSuccess].
  void addItem() {
    final current = state;
    if(current is! HomeSuccess) return;

    final data = List<String>.of(current.data);
    data.add('Item ${data.length + 1}');
    emit(current.copyWith(data: data));
  }

  /// Moves the item at [oldIndex] to [newIndex] within [HomeSuccess.data].
  ///
  /// No-op if the current state is not [HomeSuccess].
  void reOrderItem(int oldIndex, int newIndex) {
    final current = state;
    if (current is! HomeSuccess) return;

    final data = List<String>.of(current.data);
    final item = data.removeAt(oldIndex);
    data.insert(newIndex, item);

    emit(current.copyWith(data: data));
  }

  /// Toggles between grid and list layout for [HomeSuccess.isGridView].
  ///
  /// No-op if the current state is not [HomeSuccess].
  void toggleViewType() {
    final current = state;
    if (current is! HomeSuccess) return;

    emit(current.copyWith(isGridView: !current.isGridView));
  }

  /// Moves the floating action button between its top and bottom docked
  /// positions and updates [HomeSuccess.isTop] to match.
  ///
  /// Pass `isTop: true` (the default) to dock at [FloatingActionButtonLocation.endTop],
  /// or `false` to dock at [FloatingActionButtonLocation.endFloat].
  /// No-op if the current state is not [HomeSuccess] or is already at the
  /// requested position.
  void moveFab({bool isTop = true}) {
    final current = state;
    if(current is! HomeSuccess) return;

    if (isTop) {
      if (current.fabLocation == FloatingActionButtonLocation.endTop) return;
      emit(current.copyWith(fabLocation: FloatingActionButtonLocation.endTop, isTop: true));
    } else {
      if (current.fabLocation == FloatingActionButtonLocation.endFloat) return;
      emit(current.copyWith(fabLocation: FloatingActionButtonLocation.endFloat, isTop: false));
    }
  }

  // TODO: remove after verifying flavor config
  void _logFirebaseFlavor() {
    final app = Firebase.app();
    debugPrint('🔥 Firebase loaded: project=${app.options.projectId}, appId=${app.options.appId}');
  }
}
