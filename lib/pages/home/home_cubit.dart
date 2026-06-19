import 'package:flutter_bloc/flutter_bloc.dart';

import 'home_state.dart';

/// Cubit for the [HomePage].
///
/// Owns and emits [HomeState]. Extend with business logic as the
/// Home feature grows (e.g. fetching data, handling user actions).
class HomeCubit extends Cubit<HomeState> {
  /// Creates [HomeCubit] with the default [HomeState].
  HomeCubit() : super(const HomeState());
}
