import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show FloatingActionButtonLocation;
import 'package:flutter_base/utils/completer_util.dart';
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

  // Fires once the first successful load completes; awaitable via [whenReady].
  final SafeCompleter<void> _ready = SafeCompleter<void>();

  /// Completes once the first successful [initialize] finishes, or with an
  /// error if that first load fails. Await it to run post-load actions.
  Future<void> get whenReady => _ready.future;

  /// Loads the initial list of items.
  ///
  /// Emits [HomeLoading] then, after a simulated delay, [HomeSuccess] with
  /// 20 generated placeholder items. Signals [whenReady] on success, or
  /// forwards the error to it on failure.
  Future<void> initialize() async {
    emit(const HomeLoading());
    try {
      final data = List.generate(20, (i) {
        return 'Item ${i + 1}';
      }).toList();
      await Future.delayed(const Duration(seconds: 2));
      emit(HomeSuccess(data: data));
      _ready.complete();
    } catch (e, s) {
      emit(HomeError(errMess: e.toString()));
      _ready.completeError(e, s);
    }
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

  /// Removes [item] from [HomeSuccess.data].
  ///
  /// No-op if the current state is not [HomeSuccess].
  void removeItem(String item) {
    final current = state;
    if (current is! HomeSuccess) return;

    final data = List<String>.of(current.data)..remove(item);
    emit(current.copyWith(data: data));
  }

  /// Moves [item] from [HomeSuccess.data] into [HomeSuccess.archived].
  ///
  /// No-op if the current state is not [HomeSuccess] or [item] is not present.
  void archiveItem(String item) {
    final current = state;
    if (current is! HomeSuccess) return;
    if (!current.data.contains(item)) return;

    final data = List<String>.of(current.data)..remove(item);
    final archived = List<String>.of(current.archived)..add(item);
    emit(current.copyWith(data: data, archived: archived));
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
