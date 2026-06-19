import 'package:equatable/equatable.dart';

/// Animation phase of the splash screen.
enum SplashStatus {
  /// Logo mark is shown; animation has not started.
  initial,

  /// Logo has expanded to the full horizontal lockup.
  expanded,

  /// Animation complete; the page should navigate away.
  done,
}

/// Immutable state for [SplashPage], managed by [SplashCubit].
class SplashState extends Equatable {
  /// Current animation phase.
  final SplashStatus status;

  /// Creates [SplashState] starting at [SplashStatus.initial].
  const SplashState({this.status = SplashStatus.initial});

  /// Returns a copy of this state with [status] replaced.
  SplashState copyWith({SplashStatus? status}) =>
      SplashState(status: status ?? this.status);

  @override
  List<Object?> get props => [status];
}
