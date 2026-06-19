import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_state.dart';

/// Global cubit that owns app-wide UI state: theme mode and locale.
///
/// Provided at the root [AppPage] level so any widget in the tree can
/// read or mutate theme / locale without passing them down manually.
class AppCubit extends Cubit<AppState> {
  /// Creates [AppCubit] with the default [AppState].
  AppCubit() : super(const AppState());

  /// Switches the active [ThemeMode] (system / light / dark).
  void setThemeMode(ThemeMode mode) => emit(state.copyWith(themeMode: mode));

  /// Changes the active [Locale] used by [MaterialApp.router].
  void setLocale(Locale locale) => emit(state.copyWith(locale: locale));
}
