import 'package:equatable/equatable.dart';

/// Immutable state for the [HomeDetailPage], managed by [HomeDetailCubit].
sealed class HomeDetailState extends Equatable {
  const HomeDetailState();

  @override
  List<Object?> get props => [];
}

/// Initial state before [HomeDetailCubit.initialize] has run.
class HomeDetailInitial extends HomeDetailState {
  /// Creates [HomeDetailInitial].
  const HomeDetailInitial();
}

/// Emitted while [HomeDetailCubit.initialize] is loading detail content.
class HomeDetailLoading extends HomeDetailState {
  /// Creates [HomeDetailLoading].
  const HomeDetailLoading();
}

/// Detail content has loaded and is ready to render.
class HomeDetailSuccess extends HomeDetailState {
  /// The message/content to display, or null if none is available.
  final String? mess;

  /// Creates [HomeDetailSuccess].
  const HomeDetailSuccess({
    this.mess,
  });

  /// Returns a copy of this state with [mess] replaced.
  HomeDetailSuccess copyWith({
    final String? mess,
  }) {
    return HomeDetailSuccess(
      mess: mess ?? this.mess,
    );
  }

  @override
  List<Object?> get props => [mess];
}

/// Emitted when loading the detail content fails.
class HomeDetailError extends HomeDetailState {
  /// Optional error message to display; falls back to a generic message
  /// in the UI when null.
  final String? errMess;

  /// Creates [HomeDetailError].
  const HomeDetailError({
    this.errMess,
  });

  /// Returns a copy of this state with [errMess] replaced.
  HomeDetailError copyWith({
    final String? errMess,
  }) {
    return HomeDetailError(
      errMess: errMess ?? this.errMess,
    );
  }

  @override
  List<Object?> get props => [errMess];
}