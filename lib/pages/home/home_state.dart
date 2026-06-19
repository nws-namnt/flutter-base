import 'package:equatable/equatable.dart';

/// Immutable state for the [HomePage], managed by [HomeCubit].
///
/// Extend with fields as the Home feature grows.
class HomeState extends Equatable {
  /// Creates the default (empty) [HomeState].
  const HomeState();

  @override
  List<Object?> get props => [];
}
