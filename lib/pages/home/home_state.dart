import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show FloatingActionButtonLocation;

/// Immutable state for the [HomePage], managed by [HomeCubit].
///
/// Extend with fields as the Home feature grows.
sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

/// Initial state before [HomeCubit.initialize] has run.
class HomeInitial extends HomeState {
  /// Creates [HomeInitial].
  const HomeInitial();
}

/// Emitted while [HomeCubit.initialize] is fetching the item list.
class HomeLoading extends HomeState {
  /// Creates [HomeLoading].
  const HomeLoading();
}

/// The item list has loaded and the Home tab is ready to render.
class HomeSuccess extends HomeState {
  /// The list of items currently shown, in display order.
  final List<String> data;

  /// Whether items are rendered as a grid (`true`) or a reorderable list
  /// (`false`).
  final bool isGridView;

  /// Current docked position of the floating action button.
  final FloatingActionButtonLocation fabLocation;

  /// Whether the FAB is docked at the top (scrolled to bottom of the list).
  final bool isTop;

  /// Creates [HomeSuccess].
  const HomeSuccess({
    this.data = const [],
    this.isGridView = false,
    this.fabLocation = FloatingActionButtonLocation.endFloat,
    this.isTop = false,
  });

  /// Returns a copy of this state with the given fields replaced.
  HomeSuccess copyWith({
    final List<String>? data,
    final bool? isGridView,
    final FloatingActionButtonLocation? fabLocation,
    final bool? isTop,
  }) {
    return HomeSuccess(
      data: data ?? this.data,
      isGridView: isGridView ?? this.isGridView,
      fabLocation: fabLocation ?? this.fabLocation,
      isTop: isTop ?? this.isTop,
    );
  }

  @override
  List<Object?> get props => [data, isGridView, fabLocation, isTop];
}

/// Emitted when loading or updating the Home tab fails.
class HomeError extends HomeState {
  /// Optional error message to display; falls back to a generic message
  /// in the UI when null.
  final String? errMess;

  /// Creates [HomeError].
  const HomeError({this.errMess});

  /// Returns a copy of this state with [errMess] replaced.
  HomeError copyWith({final String? errMess}) {
    return HomeError(errMess: errMess ?? this.errMess);
  }

  @override
  List<Object?> get props => [errMess];
}
