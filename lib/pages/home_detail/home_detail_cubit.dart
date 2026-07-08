import 'package:bloc/bloc.dart';

import 'home_detail_state.dart';

/// Cubit for [HomeDetailPage].
///
/// Owns and emits [HomeDetailState]. Extend with real data fetching as the
/// Home detail feature grows — currently [initialize] just echoes the
/// tapped item back as the "loaded" message.
class HomeDetailCubit extends Cubit<HomeDetailState> {
  /// Creates [HomeDetailCubit] with the default [HomeDetailState].
  HomeDetailCubit() : super(const HomeDetailInitial());

  /// Loads detail content for the given [item].
  void initialize(String item) {
    emit(const HomeDetailLoading());
    emit(HomeDetailSuccess(mess: item));
  }
}
