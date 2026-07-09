import 'package:equatable/equatable.dart';

import '../../models/intro_entity.dart';

/// Immutable state for [IntroPage], managed by [IntroCubit].
class IntroState extends Equatable {
  /// Slides shown in the onboarding [PageView].
  final List<IntroEntity> items;

  /// Index of the currently visible slide.
  final int currentIndex;

  /// Creates [IntroState] with the given [items], starting at the first slide.
  const IntroState({
    required this.items,
    this.currentIndex = 0,
  });

  /// Whether [currentIndex] is the first slide.
  bool get isFirstPage => currentIndex == 0;

  /// Whether [currentIndex] is the last slide.
  bool get isLastPage => currentIndex == items.length - 1;

  /// Returns a copy of this state with [currentIndex] replaced.
  IntroState copyWith({int? currentIndex}) {
    return IntroState(
      items: items,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }

  @override
  List<Object?> get props => [items, currentIndex];
}
