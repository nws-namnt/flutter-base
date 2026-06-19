import 'package:flutter_bloc/flutter_bloc.dart';

import 'service_state.dart';

/// Cubit for the [ServicePage].
///
/// Owns and emits [ServiceState]. Extend with business logic as the
/// Service feature grows.
class ServiceCubit extends Cubit<ServiceState> {
  /// Creates [ServiceCubit] with the default [ServiceState].
  ServiceCubit() : super(const ServiceState());
}
