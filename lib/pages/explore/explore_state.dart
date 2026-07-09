import 'package:equatable/equatable.dart';

/// Immutable state for [ExplorePage], managed by [ExploreCubit].
///
/// Extend with real category/search data as the Explore feature grows.
class ExploreState extends Equatable {
  /// Every category available to browse.
  final List<String> categories;

  /// Current search query, used to filter [categories].
  final String query;

  final bool firstModalVisible;
  final bool secondModalVisible;

  /// Creates [ExploreState] with the given [categories] and an empty [query].
  const ExploreState({
    required this.categories,
    this.query = '',
    this.firstModalVisible = true,
    this.secondModalVisible = false,
  });

  /// [categories] filtered by [query] (case-insensitive substring match).
  List<String> get filteredCategories => query.isEmpty
      ? categories
      : categories
            .where(
              (category) =>
                  category.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();

  /// Returns a copy of this state with [query] replaced.
  ExploreState copyWith({
    String? query,
    bool? firstModalVisible,
    bool? secondModalVisible,
  }) => ExploreState(
    categories: categories,
    query: query ?? this.query,
    firstModalVisible: firstModalVisible ?? this.firstModalVisible,
    secondModalVisible: secondModalVisible ?? this.secondModalVisible,
  );

  @override
  List<Object?> get props => [categories, query, firstModalVisible, secondModalVisible];
}
