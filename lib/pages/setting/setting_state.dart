import 'package:equatable/equatable.dart';

/// Immutable state for the [SettingPage], managed by [SettingCubit].
///
/// Extend with fields for user preferences (theme, language, etc.) as needed.
class SettingState extends Equatable {
  /// Creates the default (empty) [SettingState].
  const SettingState();

  @override
  List<Object?> get props => [];
}
