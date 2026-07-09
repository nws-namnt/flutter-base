import 'package:bloc/bloc.dart';

import '../../models/intro_entity.dart';
import 'intro_state.dart';

/// Cubit that tracks which onboarding slide is currently visible.
///
/// [IntroPage] owns the [PageController]. It calls [onPageChanged] on every
/// swipe, and [next] / [previous] on button taps — both only update
/// [IntroState.currentIndex]; [IntroPage] listens for the change and
/// animates its [PageController] to match.
class IntroCubit extends Cubit<IntroState> {
  /// Creates [IntroCubit] with the given onboarding [items].
  IntroCubit({List<IntroEntity> items = IntroEntity.sample})
    : super(IntroState(items: items));

  /// Syncs [IntroState.currentIndex] with the page swiped to.
  ///
  /// Called from [PageView.onPageChanged] so state stays in sync with
  /// manual swipes as well as button-driven navigation.
  void onPageChanged(int index) {
    if (index == state.currentIndex) return;
    emit(state.copyWith(currentIndex: index));
  }

  /// Advances to the next slide. No-op on the last slide.
  void next() {
    if (state.isLastPage) return;
    emit(state.copyWith(currentIndex: state.currentIndex + 1));
  }

  /// Goes back to the previous slide. No-op on the first slide.
  void previous() {
    if (state.isFirstPage) return;
    emit(state.copyWith(currentIndex: state.currentIndex - 1));
  }
}
