import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Immutable state managed by [AppCubit].
///
/// Holds global UI configuration that affects the entire widget tree.
class AppState extends Equatable {
  /// Active theme mode. Defaults to [ThemeMode.system].
  final ThemeMode themeMode;

  /// Active locale. Defaults to English (`en`).
  final Locale locale;

  /// Creates [AppState] with optional overrides; both fields have sensible defaults.
  const AppState({
    this.themeMode = ThemeMode.system,
    this.locale = const Locale('en'),
  });

  /// Returns a new [AppState] with the provided fields replaced.
  AppState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
  }) =>
      AppState(
        themeMode: themeMode ?? this.themeMode,
        locale: locale ?? this.locale,
      );

  /// Properties compared by [Equatable] for value equality.
  @override
  List<Object?> get props => [themeMode, locale];
}
