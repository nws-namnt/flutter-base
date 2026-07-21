import 'package:equatable/equatable.dart';

/// Immutable state for the [ServicePage], managed by [ServiceCubit].
///
/// Extend with fields as the Service feature grows.
sealed class ServiceState extends Equatable {
  const ServiceState();

  @override
  List<Object?> get props => [];
}

/// Initial state before [ServiceCubit.initialize] has run.
class ServiceInitial extends ServiceState {
  /// Creates [ServiceInitial].
  const ServiceInitial();
}

/// Emitted while [ServiceCubit.initialize] is preparing the tab content.
class ServiceLoading extends ServiceState {
  /// Creates [ServiceLoading].
  const ServiceLoading();
}

/// The Service tab has finished loading and is ready to render.
class ServiceSuccess extends ServiceState {
  /// Creates [ServiceSuccess].
  const ServiceSuccess();
}

/// Emitted when loading the Service tab fails.
class ServiceError extends ServiceState {
  /// Optional error message to display; falls back to a generic message
  /// in the UI when null.
  final String? errMess;

  /// Creates [ServiceError].
  const ServiceError({this.errMess});

  /// Returns a copy of this state with [errMess] replaced.
  ServiceError copyWith({final String? errMess}) {
    return ServiceError(errMess: errMess ?? this.errMess);
  }

  @override
  List<Object?> get props => [errMess];
}
