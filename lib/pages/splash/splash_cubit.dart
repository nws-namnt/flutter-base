import 'package:flutter_bloc/flutter_bloc.dart';

import 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(const SplashState());

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
