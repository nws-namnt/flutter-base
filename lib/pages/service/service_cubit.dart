import 'package:flutter_base/utils/completer_util.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'service_state.dart';

/// Cubit for the [ServicePage].
///
/// Owns and emits [ServiceState]. Extend with business logic as the
/// Service feature grows.
class ServiceCubit extends Cubit<ServiceState> {
  /// Creates [ServiceCubit] with the default [ServiceState].
  ServiceCubit() : super(const ServiceInitial());

  // Fires once the first successful load completes; awaitable via [whenReady].
  final SafeCompleter<void> _ready = SafeCompleter<void>();

  /// Completes once the first successful [initialize] finishes, or with an
  /// error if that first load fails. Await it to run post-load actions.
  Future<void> get whenReady => _ready.future;

  /// Prepares the Service tab content.
  ///
  /// Emits [ServiceLoading] then, after a simulated delay, [ServiceSuccess].
  /// Signals [whenReady] on success, or forwards the error to it on failure.
  Future<void> initialize() async {
    emit(const ServiceLoading());
    try {
      await Future.delayed(const Duration(seconds: 2));
      emit(const ServiceSuccess());
      _ready.complete();
    } catch (e, s) {
      emit(ServiceError(errMess: e.toString()));
      _ready.completeError(e, s);
    }
  }
}
