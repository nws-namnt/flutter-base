import 'package:equatable/equatable.dart';
import 'package:flutter_base/common/app_enums.dart';

/// Immutable state for [SplashPage], managed by [SplashCubit].
class SplashState extends Equatable {
  /// Current animation phase.
  final LoadStatus status;

  /// Whether onboarding has already been completed/skipped on this device.
  /// Read once from [AppPreference] at the start of [SplashCubit.onInitialize];
  /// drives which route [SplashPage] navigates to on [LoadStatus.success].
  final bool isCompletedIntro;

  /// Creates [SplashState] starting at [LoadStatus.initial].
  const SplashState({
    this.status = LoadStatus.initial,
    this.isCompletedIntro = false,
  });

  /// Returns a copy of this state with [status] and/or [hasSeenIntro] replaced.
  SplashState copyWith({LoadStatus? status, bool? isCompletedIntro}) => SplashState(
    status: status ?? this.status,
    isCompletedIntro: isCompletedIntro ?? this.isCompletedIntro,
  );

  @override
  List<Object?> get props => [status, isCompletedIntro];
}
