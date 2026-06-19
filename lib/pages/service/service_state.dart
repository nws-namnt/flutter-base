import 'package:equatable/equatable.dart';

/// Immutable state for the [ServicePage], managed by [ServiceCubit].
///
/// Extend with fields as the Service feature grows.
class ServiceState extends Equatable {
  /// Creates the default (empty) [ServiceState].
  const ServiceState();

  @override
  List<Object?> get props => [];
}
