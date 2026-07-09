import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/app_enums.dart';
import '../../services/firebase_notification_service.dart';
import '../../storage/app_preference.dart';
import 'splash_state.dart';

/// Cubit that drives the two-phase splash animation sequence.
///
/// Call [onInitialize] from [SplashPage.initState] to kick off the animation.
/// The cubit emits [LoadStatus.loading] then [LoadStatus.success] in order;
/// [SplashPage] listens for `success` and navigates to [Routers.intro] (first
/// launch) or straight to [Routers.home], based on [SplashState.hasSeenIntro].
class SplashCubit extends Cubit<SplashState> {
  /// Creates [SplashCubit] starting at [LoadStatus.initial].
  SplashCubit() : super(const SplashState());

  /// Runs the two-phase animation and emits state transitions.
  ///
  /// - Reads [AppPreference.getSeenIntro] up front so [SplashState.hasSeenIntro]
  ///   is ready before [LoadStatus.success] fires.
  /// - Phase 1: waits 2 s, then emits [LoadStatus.loading] (logo expands).
  /// - Phase 2: waits 1.5 s, then emits [LoadStatus.success] (triggers navigation).
  ///
  /// Guards each emit with an [isClosed] check so disposal mid-sequence is safe.
  Future<void> onInitialize() async {
    emit(state.copyWith(isCompletedIntro: AppPreference.instance.isCompleteIntro()));

    // Request notification permission now that the splash screen is visible.
    // Fire-and-forget — the system dialog appears over the splash UI (correct
    // per Apple UX guidelines). Animation is not blocked by user response.
    FirebaseNotificationService.instance.requestPermissionAndFetchToken();

    // Phase 1 — hold mark only for 2s, then expand to horizontal
    await Future.delayed(const Duration(seconds: 2));
    if (isClosed) return;
    emit(state.copyWith(status: LoadStatus.loading));

    // Phase 2 — hold horizontal for 1.5s, then signal done
    await Future.delayed(const Duration(milliseconds: 1500));
    if (isClosed) return;
    emit(state.copyWith(status: LoadStatus.success));
  }
}
