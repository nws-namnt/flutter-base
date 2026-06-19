import 'package:flutter_bloc/flutter_bloc.dart';

import 'splash_state.dart';

/// Cubit that drives the two-phase splash animation sequence.
///
/// Call [runSequence] from [SplashPage.initState] to kick off the animation.
/// The cubit emits [SplashStatus.expanded] then [SplashStatus.done] in order;
/// [SplashPage] listens for `done` and navigates to [Routers.home].
class SplashCubit extends Cubit<SplashState> {
  /// Creates [SplashCubit] starting at [SplashStatus.initial].
  SplashCubit() : super(const SplashState());

  /// Runs the two-phase animation and emits state transitions.
  ///
  /// - Phase 1: waits 2 s, then emits [SplashStatus.expanded] (logo expands).
  /// - Phase 2: waits 1.5 s, then emits [SplashStatus.done] (triggers navigation).
  ///
  /// Guards each emit with an [isClosed] check so disposal mid-sequence is safe.
  Future<void> runSequence() async {
    // Phase 1 — hold mark only for 2s, then expand to horizontal
    await Future.delayed(const Duration(seconds: 2));
    if (isClosed) return;
    emit(state.copyWith(status: SplashStatus.expanded));

    // Phase 2 — hold horizontal for 1.5s, then signal done
    await Future.delayed(const Duration(milliseconds: 1500));
    if (isClosed) return;
    emit(state.copyWith(status: SplashStatus.done));
  }
}
