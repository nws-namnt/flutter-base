import 'package:equatable/equatable.dart';
import 'package:flutter_base/common/app_enums.dart';

/// Immutable state for [SplashPage], managed by [SplashCubit].
class SplashState extends Equatable {
  /// Current animation phase.
  final LoadStatus status;

  /// Creates [SplashState] starting at [LoadStatus.initial].
  const SplashState({this.status = LoadStatus.initial});

  /// Returns a copy of this state with [status] replaced.
  SplashState copyWith({LoadStatus? status}) =>
      SplashState(status: status ?? this.status);

  @override
  List<Object?> get props => [status];
}
