import 'package:flutter_bloc/flutter_bloc.dart';

import 'explore_state.dart';

/// Cubit for the [ExplorePage].
///
/// Owns and emits [ExploreState]. Extend with real category data / search
/// API calls as the Explore feature grows.
class ExploreCubit extends Cubit<ExploreState> {
  /// Creates [ExploreCubit] seeded with a placeholder list of categories.
  ExploreCubit()
    : super(
        const ExploreState(
          categories: [
            'Music',
            'Sports',
            'Travel',
            'Food',
            'Technology',
            'Art',
            'Fashion',
            'Gaming',
          ],
        ),
      );

  /// Updates [ExploreState.query] as the user types in the search field.
  void onSearchChanged(String query) => emit(state.copyWith(query: query));

  void toggleFirstModal() => emit(state.copyWith(firstModalVisible: !state.firstModalVisible));
  void toggleSecondModal() => emit(state.copyWith(secondModalVisible: !state.secondModalVisible));
}
